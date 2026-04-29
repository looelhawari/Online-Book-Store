/* ============================================================
   The Modern Archive — Client-side JS
   ============================================================ */

// ---- Password visibility toggle ----
function togglePassword(id) {
  const el = document.getElementById(id);
  if (!el) return;
  const icon = el.nextElementSibling?.querySelector('.material-symbols-outlined');
  el.type = el.type === 'password' ? 'text' : 'password';
  if (icon) icon.textContent = el.type === 'password' ? 'visibility' : 'visibility_off';
}

// ---- Card number formatter ----
function formatCard(el) {
  el.value = el.value.replace(/\D/g, '').replace(/(.{4})/g, '$1 ').trim().substring(0, 19);
}

// ---- Auto-dismiss flash messages ----
document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('.flash-message').forEach(el => {
    setTimeout(() => {
      el.style.transition = 'opacity 0.4s ease';
      el.style.opacity = '0';
      setTimeout(() => el.remove(), 400);
    }, 4000);
  });

  // ---- Quantity input: prevent non-numeric ----
  document.querySelectorAll('input[type="number"]').forEach(el => {
    el.addEventListener('keydown', e => {
      if (['e', 'E', '+', '-'].includes(e.key)) e.preventDefault();
    });
  });

  // ---- Confirm delete dialogs ----
  document.querySelectorAll('[data-confirm]').forEach(el => {
    el.addEventListener('click', e => {
      if (!confirm(el.dataset.confirm)) e.preventDefault();
    });
  });

  // ---- Add to cart button loading state ----
  document.querySelectorAll('form[action*="/cart/add"]').forEach(form => {
    form.addEventListener('submit', () => {
      const btn = form.querySelector('button[type="submit"]');
      if (btn) {
        btn.disabled = true;
        btn.textContent = 'Adding…';
      }
    });
  });
});
