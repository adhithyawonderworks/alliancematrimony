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
  Future<String?> signUpWithPassword(String email, String password) async {
    try {
      await client.auth.signUp(email: email, password: password);
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

      if (existing != null) {
        return existing['id'] as String;
      }

      // Create new conversation
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

        final profile = await client
            .from('matrimony_profiles')
            .select('first_name, last_name, image_url')
            .eq('user_id', otherId)
            .maybeSingle();

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
  }) {
    return client
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
        )
        .subscribe();
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
          callback: (payload) {
            onUpdate();
          },
        )
        .subscribe();
  }

  // ─── Interests Methods ────────────────────────────────────────────────────

  /// Send an interest to another user. Returns true on success.
  Future<bool> sendInterest(String receiverId, {String message = ''}) async {
    final uid = currentUserId;
    if (uid == null) return false;
    try {
      await client.from('interests').insert({
        'sender_id': uid,
        'receiver_id': receiverId,
        'message': message,
        'status': 'pending',
      });
      return true;
    } on PostgrestException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Fetch received interests for the current user, enriched with sender profile.
  Future<List<Map<String, dynamic>>> fetchReceivedInterests() async {
    final uid = currentUserId;
    if (uid == null) return [];
    try {
      final response = await client
          .from('interests')
          .select('*')
          .eq('receiver_id', uid)
          .order('created_at', ascending: false);

      final interests = List<Map<String, dynamic>>.from(response);
      final enriched = <Map<String, dynamic>>[];

      for (final interest in interests) {
        final senderId = interest['sender_id'] as String;
        final profile = await client
            .from('matrimony_profiles')
            .select(
              'first_name, last_name, age, job, place, height_cm, image_url, is_verified',
            )
            .eq('user_id', senderId)
            .maybeSingle();

        enriched.add({
          ...interest,
          'profile': profile,
          'other_user_id': senderId,
        });
      }
      return enriched;
    } on PostgrestException {
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Fetch sent interests for the current user, enriched with receiver profile.
  Future<List<Map<String, dynamic>>> fetchSentInterests() async {
    final uid = currentUserId;
    if (uid == null) return [];
    try {
      final response = await client
          .from('interests')
          .select('*')
          .eq('sender_id', uid)
          .order('created_at', ascending: false);

      final interests = List<Map<String, dynamic>>.from(response);
      final enriched = <Map<String, dynamic>>[];

      for (final interest in interests) {
        final receiverId = interest['receiver_id'] as String;
        final profile = await client
            .from('matrimony_profiles')
            .select(
              'first_name, last_name, age, job, place, height_cm, image_url, is_verified',
            )
            .eq('user_id', receiverId)
            .maybeSingle();

        enriched.add({
          ...interest,
          'profile': profile,
          'other_user_id': receiverId,
        });
      }
      return enriched;
    } on PostgrestException {
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Accept a received interest. Returns true on success.
  Future<bool> acceptInterest(String interestId) async {
    final uid = currentUserId;
    if (uid == null) return false;
    try {
      await client
          .from('interests')
          .update({'status': 'accepted'})
          .eq('id', interestId)
          .eq('receiver_id', uid);
      return true;
    } on PostgrestException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Decline a received interest. Returns true on success.
  Future<bool> declineInterest(String interestId) async {
    final uid = currentUserId;
    if (uid == null) return false;
    try {
      await client
          .from('interests')
          .update({'status': 'declined'})
          .eq('id', interestId)
          .eq('receiver_id', uid);
      return true;
    } on PostgrestException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Fetch mutual matches — interests where both sides accepted each other.
  Future<List<Map<String, dynamic>>> fetchMatches() async {
    final uid = currentUserId;
    if (uid == null) return [];
    try {
      // Fetch interests where current user accepted (receiver accepted)
      final receivedAccepted = await client
          .from('interests')
          .select('*')
          .eq('receiver_id', uid)
          .eq('status', 'accepted');

      final matches = <Map<String, dynamic>>[];

      for (final interest in List<Map<String, dynamic>>.from(
        receivedAccepted,
      )) {
        final senderId = interest['sender_id'] as String;
        // Check if sender also accepted an interest from current user
        final reverseInterest = await client
            .from('interests')
            .select('*')
            .eq('sender_id', uid)
            .eq('receiver_id', senderId)
            .eq('status', 'accepted')
            .maybeSingle();

        if (reverseInterest != null) {
          final profile = await client
              .from('matrimony_profiles')
              .select(
                'first_name, last_name, age, job, place, height_cm, image_url, is_verified',
              )
              .eq('user_id', senderId)
              .maybeSingle();

          matches.add({
            ...interest,
            'profile': profile,
            'other_user_id': senderId,
          });
        }
      }
      return matches;
    } on PostgrestException {
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Subscribe to interest changes for the current user.
  RealtimeChannel subscribeToInterests({required void Function() onUpdate}) {
    final uid = currentUserId;
    return client
        .channel('interests_$uid')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'interests',
          callback: (payload) {
            onUpdate();
          },
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
