window.openPayuCheckout = function (order) {
  var form = document.createElement('form');
  form.method = 'POST';
  form.action = order.action;
  form.style.display = 'none';

  Object.keys(order).forEach(function (key) {
    if (key === 'action' || key === 'error') return;
    var input = document.createElement('input');
    input.type = 'hidden';
    input.name = key;
    input.value = order[key] == null ? '' : String(order[key]);
    form.appendChild(input);
  });

  document.body.appendChild(form);
  form.submit();
};
