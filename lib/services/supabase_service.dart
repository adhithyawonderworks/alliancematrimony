import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // Initialize Supabase - call this in main()
  static Future<void> initialize() async {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
        'SUPABASE_URL and SUPABASE_ANON_KEY must be defined using --dart-define.',
      );
    }

    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  Future<Map<String, dynamic>?> fetchConnectedProfile(String userId) async {
    try {
      final response = await client.rpc(
        'get_connected_matrimony_profile',
        params: {'target_user_id': userId},
      );
      if (response is Map) return Map<String, dynamic>.from(response);
      return null;
    } catch (_) {
      return null;
    }
  }

  // Get Supabase client only when the SDK has been initialized.
  SupabaseClient? get clientOrNull {
    try {
      return Supabase.instance.client;
    } on AssertionError {
      return null;
    } catch (_) {
      return null;
    }
  }

  // Get Supabase client
  SupabaseClient get client {
    final safeClient = clientOrNull;
    if (safeClient == null) {
      throw StateError(
        'Supabase has not been initialized. Call SupabaseService.initialize() before using the client.',
      );
    }
    return safeClient;
  }

  // Get current user id
  String? get currentUserId => clientOrNull?.auth.currentUser?.id;
  String? get currentUserEmail => clientOrNull?.auth.currentUser?.email;

  Future<String?> updateAccountPassword(String password) async {
    try {
      await client.auth.updateUser(UserAttributes(password: password));
      return null;
    } on AuthException catch (error) {
      return error.message;
    } catch (error) {
      return error.toString();
    }
  }

  // ─── Matrimony Profile Methods ───────────────────────────────────────────

  /// Fetch the current user's matrimony profile. Returns null if not found.
  Future<Map<String, dynamic>?> fetchProfile() async {
    final uid = currentUserId;
    if (uid == null) return null;
    try {
      final response = await client
          .from('matrimony_profiles')
          .select()
          .eq('user_id', uid)
          .maybeSingle();
      return response;
    } on PostgrestException {
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Upsert (create or update) the current user's matrimony profile.
  /// Returns true on success, false on failure.
  Future<bool> upsertProfile(Map<String, dynamic> data) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not logged in. Please sign in again.');
    try {
      final payload = Map<String, dynamic>.from(data);
      payload['user_id'] = uid;

      // Use native Supabase upsert — inserts if no row exists, updates if it does.
      // Requires a UNIQUE constraint on user_id (see migration 20260717190000).
      await client
          .from('matrimony_profiles')
          .upsert(payload, onConflict: 'user_id');

      return true;
    } on PostgrestException catch (e) {
      throw Exception('Save failed: ${e.message} (code: ${e.code})');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> recordTruthfulnessSubmission({
    required DateTime acceptedAt,
    required Map<String, dynamic> profileSnapshot,
  }) async {
    await client.from('profile_truthfulness_submissions').insert({
      'user_id': currentUserId,
      'accepted_at': acceptedAt.toUtc().toIso8601String(),
      'agreement_version': 'truthful-profile-v1',
      'profile_snapshot': profileSnapshot,
    });
  }

  Future<String> uploadProfilePhoto(XFile image) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not logged in. Please sign in again.');
    final extension = image.name.contains('.')
        ? image.name.split('.').last.toLowerCase()
        : 'jpg';
    final path = '$uid/profile.$extension';
    final contentType = switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
    await client.storage
        .from('profile-photos')
        .uploadBinary(
          path,
          await image.readAsBytes(),
          fileOptions: FileOptions(upsert: true, contentType: contentType),
        );
    return client.storage.from('profile-photos').getPublicUrl(path);
  }

  /// Uploads an Aadhar card image to the private 'identity-documents' bucket
  /// and marks verification as pending admin review.
  /// TODO(aadhar-ocr): No OCR/verification API is integrated yet. This currently
  /// stores the image and sets status to 'pending' for manual admin review.
  /// When an OCR provider is chosen, call it here (or via a Supabase Edge
  /// Function) to auto-extract/match the name before falling back to manual review.
  Future<bool> submitAadharVerification({
    required XFile image,
    required String aadharName,
  }) async {
    final uid = currentUserId;
    if (uid == null) return false;
    try {
      final extension = image.name.contains('.')
          ? image.name.split('.').last.toLowerCase()
          : 'jpg';
      final path = '$uid/aadhar.$extension';
      final contentType = switch (extension) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        _ => 'image/jpeg',
      };
      await client.storage
          .from('identity-documents')
          .uploadBinary(
            path,
            await image.readAsBytes(),
            fileOptions: FileOptions(upsert: true, contentType: contentType),
          );
      await client.from('matrimony_profiles').update({
        'aadhar_name': aadharName,
        'aadhar_image_url': path,
        'aadhar_verification_status': 'pending',
      }).eq('user_id', uid);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Creates a short-lived signed URL to display the private Aadhar image
  /// (e.g. so the user can review what they submitted).
  Future<String?> getAadharImageSignedUrl(String storagePath) async {
    if (storagePath.isEmpty) return null;
    try {
      return await client.storage
          .from('identity-documents')
          .createSignedUrl(storagePath, 60 * 10);
    } catch (_) {
      return null;
    }
  }

  /// Saves the local security (passcode/biometric) settings to the backend so
  /// they can be recovered on another device. [passcodeHash] should already be
  /// hashed client-side (never send a plaintext passcode).
  Future<bool> updateSecuritySettings({
    String? passcodeHash,
    bool? biometricEnabled,
  }) async {
    final uid = currentUserId;
    if (uid == null) return false;
    final fields = <String, dynamic>{
      if (passcodeHash != null) 'passcode_hash': passcodeHash,
      if (biometricEnabled != null) 'biometric_enabled': biometricEnabled,
    };
    if (fields.isEmpty) return true;
    try {
      await client.from('matrimony_profiles').update(fields).eq('user_id', uid);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Update specific fields of the current user's matrimony profile.
  /// Returns true on success, false on failure.
  Future<bool> updateProfileFields(Map<String, dynamic> fields) async {
    final uid = currentUserId;
    if (uid == null) return false;
    try {
      await client.from('matrimony_profiles').update(fields).eq('user_id', uid);
      return true;
    } on PostgrestException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Permanently deletes the current user's app data and Auth account.
  Future<void> deleteCurrentUserData() async {
    if (currentUserId == null) {
      throw Exception('No signed-in user was found.');
    }
    try {
      await client.rpc('delete_my_account_data');
      try {
        await client.auth.signOut();
      } on AuthException {
        // The Auth user may already be invalidated by the deletion cascade.
      }
    } on PostgrestException catch (e) {
      throw Exception('Account deletion failed: ${e.message}');
    } on AuthException catch (e) {
      throw Exception('Account deletion failed: ${e.message}');
    }
  }

  // ─── Phone OTP Auth Methods ───────────────────────────────────────────────

  /// Send a phone OTP via Supabase Auth (SMS).
  /// [phone] must be in E.164 format, e.g. +919876543210
  /// Returns null on success, or an error message string on failure.
  Future<String?> sendPhoneOtp(String phone) async {
    try {
      await client.auth.signInWithOtp(phone: phone);
      return null; // success
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  /// Verify the phone OTP entered by the user.
  /// Returns null on success, or an error message string on failure.
  Future<String?> verifyPhoneOtp(String phone, String token) async {
    try {
      await client.auth.verifyOTP(
        phone: phone,
        token: token,
        type: OtpType.sms,
      );
      return null; // success
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // ─── Email OTP Auth Methods ───────────────────────────────────────────────

  /// Send an email OTP via Supabase Auth.
  /// Returns null on success, or an error message string on failure.
  Future<String?> sendEmailOtp(String email) async {
    try {
      await client.auth.signInWithOtp(email: email);
      return null; // success
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  /// Verify the email OTP entered by the user.
  /// Returns null on success, or an error message string on failure.
  Future<String?> verifyEmailOtp(String email, String token) async {
    try {
      await client.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.email,
      );
      return null; // success
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // ─── Email + Password Auth Methods ───────────────────────────────────────

  /// Sign in with email and password.
  /// Returns null on success, or an error message string on failure.
  Future<String?> signInWithPassword(String email, String password) async {
    try {
      await client.auth.signInWithPassword(email: email, password: password);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  /// Sign up with email and password.
  /// Returns null on success, or an error message string on failure.
  Future<String?> signUpWithPassword(
    String email,
    String password, {
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await client.auth.signUp(
        email: email,
        password: password,
        data: metadata,
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // ─── Chat Methods ─────────────────────────────────────────────────────────

  /// Get or create a conversation between the current user and another user.
  Future<String?> getOrCreateConversation(String otherUserId) async {
    final uid = currentUserId;
    if (uid == null) return null;
    try {
      // Try to find existing conversation
      final existing = await client
          .from('chat_conversations')
          .select('id')
          .or(
            'and(participant_one.eq.$uid,participant_two.eq.$otherUserId),and(participant_one.eq.$otherUserId,participant_two.eq.$uid)',
          )
          .maybeSingle();

      if (existing != null) return existing['id'] as String;

      final created = await client
          .from('chat_conversations')
          .insert({'participant_one': uid, 'participant_two': otherUserId})
          .select('id')
          .single();

      return created['id'] as String;
    } on PostgrestException {
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Fetch all conversations for the current user, joined with the other participant's profile.
  Future<List<Map<String, dynamic>>> fetchConversations() async {
    final uid = currentUserId;
    if (uid == null) return [];
    try {
      final response = await client
          .from('chat_conversations')
          .select('*')
          .or('participant_one.eq.$uid,participant_two.eq.$uid')
          .order('last_message_at', ascending: false);

      final conversations = List<Map<String, dynamic>>.from(response);

      // Enrich each conversation with the other participant's profile
      final enriched = <Map<String, dynamic>>[];
      for (final conv in conversations) {
        final otherId = conv['participant_one'] == uid
            ? conv['participant_two'] as String
            : conv['participant_one'] as String;

        final profile = await fetchConnectedProfile(otherId);

        enriched.add({
          ...conv,
          'other_user_id': otherId,
          'other_name': profile != null
              ? '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}'
                    .trim()
              : 'Unknown',
          'other_avatar': profile?['image_url'] ?? '',
        });
      }
      return enriched;
    } on PostgrestException {
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Fetch messages for a conversation, ordered oldest first.
  Future<List<Map<String, dynamic>>> fetchMessages(
    String conversationId,
  ) async {
    try {
      final response = await client
          .from('chat_messages')
          .select('*')
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException {
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<void> markReceivedMessagesRead(String conversationId) async {
    final uid = currentUserId;
    if (uid == null) return;
    try {
      await client
          .from('chat_messages')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('conversation_id', conversationId)
          .neq('sender_id', uid)
          .eq('is_read', false);
    } catch (_) {}
  }

  /// Send a message in a conversation. Returns the inserted message or null.
  Future<Map<String, dynamic>?> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    final uid = currentUserId;
    if (uid == null) return null;
    try {
      final message = await client
          .from('chat_messages')
          .insert({
            'conversation_id': conversationId,
            'sender_id': uid,
            'content': content,
          })
          .select()
          .single();

      // Update last_message on the conversation
      await client
          .from('chat_conversations')
          .update({
            'last_message': content,
            'last_message_at': DateTime.now().toIso8601String(),
          })
          .eq('id', conversationId);

      return message;
    } on PostgrestException {
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Subscribe to new messages in a conversation.
  RealtimeChannel subscribeToMessages({
    required String conversationId,
    required void Function(Map<String, dynamic> message) onNewMessage,
    void Function(Map<String, dynamic> message)? onMessageUpdated,
  }) {
    final channel = client
        .channel('chat_messages_$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) {
            onNewMessage(Map<String, dynamic>.from(payload.newRecord));
          },
        );
    if (onMessageUpdated != null) {
      channel.onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'chat_messages',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'conversation_id',
          value: conversationId,
        ),
        callback: (payload) {
          onMessageUpdated(Map<String, dynamic>.from(payload.newRecord));
        },
      );
    }
    return channel.subscribe();
  }

  /// Subscribe to conversation list updates (last_message changes).
  RealtimeChannel subscribeToConversations({
    required void Function() onUpdate,
  }) {
    final uid = currentUserId;
    return client
        .channel('chat_conversations_$uid')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'chat_conversations',
          callback: (payload) => onUpdate(),
        )
        .subscribe();
  }

  // ─── Discovery, Shortlist, Blocking, and Verification ─────────────────────

  Future<List<Map<String, dynamic>>> discoverProfiles() async {
    if (currentUserId == null) return [];
    try {
      final response = await client.rpc('discover_matrimony_profiles');
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException {
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<Set<String>> fetchSavedProfileIds() async {
    final uid = currentUserId;
    if (uid == null) return {};
    try {
      final response = await client
          .from('saved_profiles')
          .select('saved_user_id')
          .eq('user_id', uid);
      return List<Map<String, dynamic>>.from(
        response,
      ).map((row) => row['saved_user_id'] as String).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<bool> setProfileSaved(String profileId, {required bool saved}) async {
    final uid = currentUserId;
    if (uid == null) return false;
    try {
      if (saved) {
        await client.from('saved_profiles').upsert({
          'user_id': uid,
          'saved_user_id': profileId,
        });
      } else {
        await client
            .from('saved_profiles')
            .delete()
            .eq('user_id', uid)
            .eq('saved_user_id', profileId);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> blockUser(String blockedUserId) async {
    final uid = currentUserId;
    if (uid == null) return false;
    try {
      await client.from('blocked_users').upsert({
        'user_id': uid,
        'blocked_user_id': blockedUserId,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> unblockUser(String blockedUserId) async {
    final uid = currentUserId;
    if (uid == null) return false;
    try {
      await client
          .from('blocked_users')
          .delete()
          .eq('user_id', uid)
          .eq('blocked_user_id', blockedUserId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Set<String>> fetchBlockedUserIds() async {
    final uid = currentUserId;
    if (uid == null) return {};
    try {
      final response = await client
          .from('blocked_users')
          .select('blocked_user_id')
          .eq('user_id', uid);
      return List<Map<String, dynamic>>.from(
        response,
      ).map((row) => row['blocked_user_id'] as String).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<bool> requestPhotoVerification(String photoUrl) async {
    final uid = currentUserId;
    if (uid == null || photoUrl.trim().isEmpty) return false;
    try {
      await client.from('photo_verification_requests').insert({
        'user_id': uid,
        'photo_url': photoUrl.trim(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> submitAddressVerification({
    required String documentType,
    required XFile frontImage,
    required XFile backImage,
  }) async {
    final uid = currentUserId;
    if (uid == null) return false;
    try {
      final frontPath =
          '$uid/front_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final backPath = '$uid/back_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final bucket = client.storage.from('address-verification');
      await bucket.uploadBinary(
        frontPath,
        await frontImage.readAsBytes(),
        fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
      );
      await bucket.uploadBinary(
        backPath,
        await backImage.readAsBytes(),
        fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
      );
      await client.from('address_verification_documents').upsert({
        'user_id': uid,
        'document_type': documentType,
        'front_object_path': frontPath,
        'back_object_path': backPath,
        'submitted_at': DateTime.now().toUtc().toIso8601String(),
      });
      await client
          .from('matrimony_profiles')
          .update({'address_verification_status': 'pending'})
          .eq('user_id', uid);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<String?> fetchPhotoVerificationStatus() async {
    final uid = currentUserId;
    if (uid == null) return null;
    try {
      final response = await client
          .from('photo_verification_requests')
          .select('status')
          .eq('user_id', uid)
          .order('submitted_at', ascending: false)
          .limit(1)
          .maybeSingle();
      return response?['status'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<String> fetchAddressVerificationStatus() async {
    final uid = currentUserId;
    if (uid == null) return 'not_submitted';
    try {
      final profile = await client
          .from('matrimony_profiles')
          .select('address_verification_status')
          .eq('user_id', uid)
          .maybeSingle();
      return profile?['address_verification_status'] as String? ??
          'not_submitted';
    } catch (_) {
      return 'not_submitted';
    }
  }

  // ─── Interests Methods ────────────────────────────────────────────────────

  Future<bool> sendInterest(String receiverId, {String message = ''}) async {
    final uid = currentUserId;
    if (uid == null) return false;
    try {
      final existing = await client
          .from('interests')
          .select('id, status')
          .eq('sender_id', uid)
          .eq('receiver_id', receiverId)
          .maybeSingle();
      if (existing != null) {
        if (existing['status'] != 'declined') return true;
        await client
            .from('interests')
            .update({'status': 'pending', 'message': message})
            .eq('id', existing['id'] as String)
            .eq('sender_id', uid);
        return true;
      }
      await client.from('interests').insert({
        'sender_id': uid,
        'receiver_id': receiverId,
        'message': message,
        'status': 'pending',
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchReceivedInterests() async {
    final uid = currentUserId;
    if (uid == null) return [];
    try {
      final response = await client
          .from('interests')
          .select('*')
          .eq('receiver_id', uid)
          .order('created_at', ascending: false);
      final enriched = <Map<String, dynamic>>[];
      for (final interest in List<Map<String, dynamic>>.from(response)) {
        final senderId = interest['sender_id'] as String;
        enriched.add({
          ...interest,
          'profile': await fetchConnectedProfile(senderId),
          'other_user_id': senderId,
        });
      }
      return enriched;
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchSentInterests() async {
    final uid = currentUserId;
    if (uid == null) return [];
    try {
      final response = await client
          .from('interests')
          .select('*')
          .eq('sender_id', uid)
          .order('created_at', ascending: false);
      final enriched = <Map<String, dynamic>>[];
      for (final interest in List<Map<String, dynamic>>.from(response)) {
        final receiverId = interest['receiver_id'] as String;
        enriched.add({
          ...interest,
          'profile': await fetchConnectedProfile(receiverId),
          'other_user_id': receiverId,
        });
      }
      return enriched;
    } catch (_) {
      return [];
    }
  }

  Future<bool> acceptInterest(String interestId) async {
    final uid = currentUserId;
    if (uid == null) return false;
    try {
      final updated = await client
          .from('interests')
          .update({'status': 'accepted'})
          .eq('id', interestId)
          .eq('receiver_id', uid)
          .select('id')
          .maybeSingle();
      return updated != null;
    } catch (_) {
      return false;
    }
  }

  Future<bool> declineInterest(String interestId) async {
    final uid = currentUserId;
    if (uid == null) return false;
    try {
      final updated = await client
          .from('interests')
          .update({'status': 'declined'})
          .eq('id', interestId)
          .eq('receiver_id', uid)
          .select('id')
          .maybeSingle();
      return updated != null;
    } catch (_) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchMatches() async {
    final uid = currentUserId;
    if (uid == null) return [];
    try {
      final response = await client
          .from('interests')
          .select('*')
          .eq('status', 'accepted')
          .or('sender_id.eq.$uid,receiver_id.eq.$uid');
      final matches = <Map<String, dynamic>>[];
      final addedUserIds = <String>{};
      for (final interest in List<Map<String, dynamic>>.from(response)) {
        final otherUserId = interest['sender_id'] == uid
            ? interest['receiver_id'] as String
            : interest['sender_id'] as String;
        if (!addedUserIds.add(otherUserId)) continue;
        matches.add({
          ...interest,
          'profile': await fetchConnectedProfile(otherUserId),
          'other_user_id': otherUserId,
        });
      }
      return matches;
    } catch (_) {
      return [];
    }
  }

  RealtimeChannel subscribeToInterests({required void Function() onUpdate}) {
    final uid = currentUserId;
    return client
        .channel('interests_$uid')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'interests',
          callback: (payload) => onUpdate(),
        )
        .subscribe();
  }

  // ─── Report Methods ───────────────────────────────────────────────────────

  /// Submit a report against another user. Returns true on success.
  Future<bool> reportUser({
    required String reportedUserId,
    required String reason,
    String message = '',
  }) async {
    final uid = currentUserId;
    if (uid == null) return false;
    try {
      await client.from('user_reports').insert({
        'reporter_id': uid,
        'reported_user_id': reportedUserId,
        'reason': reason,
        'message': message,
      });
      return true;
    } on PostgrestException {
      return false;
    } catch (_) {
      return false;
    }
  }

  // ─── Premium Purchases Methods ────────────────────────────────────────────

  /// Fetch all premium purchases for the current user.
  Future<List<Map<String, dynamic>>> fetchPurchases() async {
    final uid = currentUserId;
    if (uid == null) return [];
    try {
      final response = await client
          .from('premium_purchases')
          .select('*')
          .eq('user_id', uid)
          .order('purchased_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException {
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Fetch the active premium purchase for the current user.
  Future<Map<String, dynamic>?> fetchActivePurchase() async {
    final uid = currentUserId;
    if (uid == null) return null;
    try {
      final response = await client
          .from('premium_purchases')
          .select('*')
          .eq('user_id', uid)
          .eq('is_active', true)
          .order('purchased_at', ascending: false)
          .limit(1)
          .maybeSingle();
      return response;
    } on PostgrestException {
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Record a new premium purchase. Returns true on success.
  Future<bool> recordPurchase({
    required int amountInr,
    String purchaseType = 'full_access',
    String paymentReference = '',
  }) async {
    final uid = currentUserId;
    if (uid == null) return false;
    try {
      final now = DateTime.now();
      final validUntil = now.add(const Duration(days: 730)); // 2 years
      final invoiceNumber =
          'INV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(7)}';
      await client.from('premium_purchases').insert({
        'user_id': uid,
        'purchase_type': purchaseType,
        'amount_inr': amountInr,
        'payment_reference': paymentReference,
        'purchased_at': now.toIso8601String(),
        'valid_until': validUntil.toIso8601String(),
        'is_active': true,
        'invoice_number': invoiceNumber,
      });
      return true;
    } on PostgrestException {
      return false;
    } catch (_) {
      return false;
    }
  }

  // ─── Notifications Methods ────────────────────────────────────────────────

  /// Fetch notifications for the current user.
  Future<List<Map<String, dynamic>>> fetchNotifications({
    int limit = 50,
  }) async {
    final uid = currentUserId;
    if (uid == null) return [];
    try {
      final response = await client
          .from('notifications')
          .select('*')
          .eq('user_id', uid)
          .order('created_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException {
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Count unread notifications for the current user.
  Future<int> fetchUnreadNotificationCount() async {
    final uid = currentUserId;
    if (uid == null) return 0;
    try {
      final response = await client
          .from('notifications')
          .select('id')
          .eq('user_id', uid)
          .eq('is_read', false);
      return (response as List).length;
    } on PostgrestException {
      return 0;
    } catch (_) {
      return 0;
    }
  }

  /// Mark all notifications as read.
  Future<void> markAllNotificationsRead() async {
    final uid = currentUserId;
    if (uid == null) return;
    try {
      await client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', uid)
          .eq('is_read', false);
    } catch (_) {}
  }

  /// Subscribe to new notifications for the current user.
  RealtimeChannel subscribeToNotifications({
    required void Function(Map<String, dynamic>) onNew,
  }) {
    final uid = currentUserId;
    return client
        .channel('notifications_$uid')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: uid ?? '',
          ),
          callback: (payload) {
            onNew(Map<String, dynamic>.from(payload.newRecord));
          },
        )
        .subscribe();
  }
}
