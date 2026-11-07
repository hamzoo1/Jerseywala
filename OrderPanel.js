'use client';

import { useState } from 'react';
import { buildOrderMessage, formatPKR, instagramLinks } from '@/lib/utils';
import { createClient } from '@/lib/supabase/client';

// Copies text to the clipboard. Works on modern browsers and has a fallback for older ones.
async function copyText(text) {
  try {
    if (navigator.clipboard && window.isSecureContext) {
      await navigator.clipboard.writeText(text);
      return true;
    }
  } catch (e) {
    // fall through to the old method
  }
  try {
    const ta = document.createElement('textarea');
    ta.value = text;
    ta.setAttribute('readonly', '');
    ta.style.position = 'fixed';
    ta.style.opacity = '0';
    document.body.appendChild(ta);
    ta.select();
    ta.setSelectionRange(0, text.length);
    const ok = document.execCommand('copy');
    document.body.removeChild(ta);
    return ok;
  } catch (e) {
    return false;
  }
}

export default function OrderPanel({ product, instagramUsername }) {
  const { id, name, price, sizes, stock, available } = product;
  const sizeList = sizes && sizes.length > 0 ? sizes : [];
  const maxQty = Math.max(1, Math.min(Number(stock) || 1, 10));

  const [size, setSize] = useState('');
  const [quantity, setQuantity] = useState(1);
  const [error, setError] = useState('');
  const [open, setOpen] = useState(false);
  const [message, setMessage] = useState('');
  const [copied, setCopied] = useState(false);

  const links = instagramLinks(instagramUsername);

  function handleOrder() {
    if (!available) return;
    if (sizeList.length > 0 && !size) {
      setError('Please select a size first.');
      return;
    }
    setError('');

    const text = buildOrderMessage({
      name,
      price,
      size: size || 'Standard',
      quantity,
    });
    setMessage(text);
    setOpen(true);

    // 1) Start copying first (must happen inside the click), 2) then open Instagram.
    copyText(text).then(setCopied);
    window.open(links.dm, '_blank', 'noopener,noreferrer');

    // Record the order request so it shows up in Admin -> Orders.
    // Runs in the background; if it fails, ordering on Instagram still works.
    try {
      createClient()
        .rpc('place_order', { p_product_id: id, p_size: size || '', p_quantity: quantity })
        .then(
          () => {},
          () => {}
        );
    } catch (e) {
      // ignore
    }
  }

  async function handleCopyAgain() {
    const ok = await copyText(message);
    setCopied(ok);
  }

  return (
    <div>
      {sizeList.length > 0 && (
        <div>
          <div className="mb-2 flex items-center justify-between">
            <p className="text-sm font-semibold uppercase tracking-wider">Size</p>
            {size && <p className="text-sm text-white/60">Selected: {size}</p>}
          </div>
          <div className="flex flex-wrap gap-2">
            {sizeList.map((s) => (
              <button
                key={s}
                type="button"
                disabled={!available}
                onClick={() => {
                  setSize(s);
                  setError('');
                }}
                className={`h-11 min-w-[3.25rem] rounded-lg border px-4 text-sm font-semibold transition disabled:opacity-40 ${
                  size === s
                    ? 'border-brand bg-brand text-white'
                    : 'border-line bg-panel text-white/80 hover:border-white/50'
                }`}
              >
                {s}
              </button>
            ))}
          </div>
        </div>
      )}

      <div className="mt-6">
        <p className="mb-2 text-sm font-semibold uppercase tracking-wider">Quantity</p>
        <div className="inline-flex items-center rounded-lg border border-line bg-panel">
          <button
            type="button"
            disabled={!available || quantity <= 1}
            onClick={() => setQuantity((q) => Math.max(1, q - 1))}
            className="h-11 w-11 text-xl transition hover:text-brand disabled:opacity-30"
            aria-label="Decrease quantity"
          >
            −
          </button>
          <span className="w-12 text-center font-semibold" aria-live="polite">
            {quantity}
          </span>
          <button
            type="button"
            disabled={!available || quantity >= maxQty}
            onClick={() => setQuantity((q) => Math.min(maxQty, q + 1))}
            className="h-11 w-11 text-xl transition hover:text-brand disabled:opacity-30"
            aria-label="Increase quantity"
          >
            +
          </button>
        </div>
      </div>

      {error && (
        <p role="alert" className="mt-4 rounded-lg border border-brand/50 bg-brand/10 px-3 py-2 text-sm text-red-300">
          {error}
        </p>
      )}

      <button
        type="button"
        onClick={handleOrder}
        disabled={!available}
        className="btn-red mt-6 w-full py-4 text-base uppercase tracking-wider"
      >
        {available ? 'Order via Instagram' : 'Sold Out'}
      </button>
      {available && (
        <p className="mt-2 text-center text-xs text-white/50">
          No payment online. We confirm availability and delivery with you on Instagram.
        </p>
      )}

      {open && (
        <div
          className="fixed inset-0 z-50 flex items-end justify-center bg-black/80 p-0 sm:items-center sm:p-4"
          role="dialog"
          aria-modal="true"
          aria-label="Order on Instagram"
        >
          <div className="max-h-[92vh] w-full max-w-lg overflow-y-auto rounded-t-2xl border border-line bg-charcoal p-6 sm:rounded-2xl">
            <div className="flex items-start justify-between gap-4">
              <h3 className="font-heading text-2xl font-bold">Almost done!</h3>
              <button
                type="button"
                onClick={() => setOpen(false)}
                aria-label="Close"
                className="flex h-9 w-9 items-center justify-center rounded-lg border border-line text-lg hover:border-white/50"
              >
                ×
              </button>
            </div>

            <ol className="mt-3 space-y-1.5 text-sm text-white/80">
              <li>
                <span className="font-semibold text-brand">1.</span> Your order message is{' '}
                {copied ? <span className="font-semibold text-green-400">copied ✓</span> : 'ready below. Tap “Copy message”.'}
              </li>
              <li>
                <span className="font-semibold text-brand">2.</span> Instagram should have opened in a new tab. If it did
                not, tap “Open Instagram chat”.
              </li>
              <li>
                <span className="font-semibold text-brand">3.</span> <strong>Paste</strong> the message into the chat and
                press <strong>Send</strong>.
              </li>
            </ol>

            <textarea
              readOnly
              value={message}
              rows={9}
              onFocus={(e) => e.target.select()}
              className="input mt-4 resize-none font-mono text-xs leading-relaxed"
            />

            <div className="mt-4 grid gap-3 sm:grid-cols-2">
              <button type="button" onClick={handleCopyAgain} className="btn-ghost">
                {copied ? 'Copied ✓ (copy again)' : 'Copy message'}
              </button>
              <a href={links.dm} target="_blank" rel="noopener noreferrer" className="btn-red">
                Open Instagram chat
              </a>
            </div>

            <p className="mt-4 text-center text-xs text-white/50">
              Instagram cannot open the chat?{' '}
              <a
                href={links.profile}
                target="_blank"
                rel="noopener noreferrer"
                className="font-semibold text-white underline hover:text-brand"
              >
                Visit @{links.username} on Instagram
              </a>{' '}
              and send us the message there.
            </p>
            <p className="mt-2 text-center text-xs text-white/40">
              Total for this order: {formatPKR(price * quantity)}
            </p>
          </div>
        </div>
      )}
    </div>
  );
}
