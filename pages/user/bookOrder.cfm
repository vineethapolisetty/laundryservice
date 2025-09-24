<cfif NOT structKeyExists(session, "userid")>
  <cflocation url="/laundryservice/index.cfm?fuse=login">
</cfif>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Order Booking</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">

  <style>
    :root{
      --brand:#5b5ee1; --bg:#f4f6f8; --card:#ffffff; --text:#1f2937; --muted:#6b7280; --border:#e5e7eb; --shadow:0 10px 24px rgba(0,0,0,.06);
    }
    *{box-sizing:border-box}
    body{ margin:0; font-family: Inter, system-ui, -apple-system, Segoe UI, Roboto, Arial, sans-serif; background: var(--bg); color: var(--text); }

    .topbar{ display:flex; align-items:center; gap:12px; padding:16px; background:var(--card); position:sticky; top:0; z-index:20; border-bottom:1px solid var(--border); }
    .back{ height:40px; width:40px; border:none; border-radius:12px; display:grid; place-items:center; background:#eef1ff; color:var(--brand); cursor:pointer; transition:transform .1s ease; }
    .back:active{ transform:scale(.97); }
    .title{ font-size:18px; font-weight:700; }

    .wrapper{ max-width:720px; margin: 18px auto 140px; padding: 0 16px; }
    .card{ background:var(--card); border:1px solid var(--border); border-radius:16px; padding:18px; box-shadow: var(--shadow); margin-bottom:16px; }
    .card h2{ margin:0 0 12px; font-size:16px; color:#374151; }

    select, input[type="text"]{ width:100%; padding:12px 12px; border-radius:12px; border:1px solid #d1d5db; outline:none; transition: box-shadow .15s, border-color .15s; font-size:14px; background:#fff; }
    select:focus, input[type="text"]:focus{ border-color: var(--brand); box-shadow: 0 0 0 4px rgba(91,94,225,.12); }
    .muted{ color:var(--muted); font-size:12px; margin-top:6px; }

    .service-grid{ display:grid; grid-template-columns: 1fr 1fr; gap:12px; }
    .service-box{ border:2px solid var(--border); border-radius:14px; padding:16px; background:#fff; text-align:center; cursor:pointer; transition: all .15s ease; min-height:140px; display:flex; flex-direction:column; justify-content:center; align-items:center; }
    .service-box:hover{ transform: translateY(-1px); }
    .service-box.active{ border-color: var(--brand); background: #f6f6ff; box-shadow: 0 8px 20px rgba(91,94,225,.15); }
    .service-emoji{ font-size:28px; margin-bottom:6px; }
    .service-box strong{ font-size:14px; }
    .service-box small{ display:block; color:var(--muted); font-size:12px; margin-top:4px; }

    .items{ display:flex; flex-direction:column; gap:10px; }
    .item-row{ display:flex; align-items:center; justify-content:space-between; padding:12px 14px; border:1px solid #eee; border-radius:12px; background:#fff; }
    .item-name{ display:flex; align-items:center; gap:8px; font-weight:600; }
    .item-controls{ display:flex; align-items:center; gap:8px; }
    .btn-q{ width:36px; height:36px; border:none; border-radius:10px; background:#eef2f7; font-weight:800; font-size:18px; cursor:pointer; transition:transform .1s ease, background .15s ease; }
    .btn-q:hover{ background:#e3e9f3; }
    .btn-q:active{ transform:scale(.96); }
    .qty{ width:44px; text-align:center; border:none; background:transparent; font-weight:800; font-size:16px; }

    .summary-row{ display:flex; justify-content:space-between; margin:8px 0; font-size:14px; }
    .summary-row strong{ font-weight:700; }
    .total{ display:flex; justify-content:space-between; align-items:center; margin-top:12px; padding-top:12px; border-top:1px dashed #e5e7eb; font-weight:800; font-size:18px; color:var(--brand); }

    .confirm-bar{ position: fixed; left:0; right:0; bottom:0; z-index:30; background:var(--card); border-top:1px solid var(--border); box-shadow: 0 -10px 24px rgba(0,0,0,.06); }
    .confirm-inner{ max-width:720px; margin:0 auto; padding:14px 16px; display:flex; gap:12px; align-items:center; }
    .pill{ background:#f3f4ff; color:#4338ca; border-radius:999px; padding:8px 12px; font-weight:700; font-size:14px; }
    .btn-primary{ margin-left:auto; padding:14px 16px; background:var(--brand); color:#fff; border:none; border-radius:12px; cursor:pointer; font-weight:800; font-size:15px; min-width:180px; transition:transform .08s ease, opacity .15s; box-shadow: 0 10px 24px rgba(91,94,225,.25); }
    .btn-primary:active{ transform: translateY(1px); }
    .btn-primary[disabled]{ opacity:.6; cursor:not-allowed; box-shadow:none; }

    @media (max-width:560px){
      .wrapper{ margin-bottom: 160px; }
      .confirm-inner{ flex-wrap:wrap; gap:8px; }
      .btn-primary{ width:100%; min-width:unset; }
    }
  </style>
</head>

<body>

  <header class="topbar">
    <button class="back" onclick="history.back()" aria-label="Back">
      <i class="fa-solid fa-chevron-left"></i>
    </button>
    <div class="title">Order Booking</div>
  </header>

  <div class="wrapper">
    <!-- Stores (unchanged query) -->
    <cfquery name="qStores" datasource="laundryservice">
      SELECT s.StoreID, s.StoreName, r.RegionName
      FROM Stores s
      INNER JOIN Regions r ON s.RegionID = r.RegionID
      ORDER BY r.RegionName, s.StoreName
    </cfquery>

    <form method="post" action="/laundryservice/index.cfm?fuse=createorder" id="orderForm">
      <!-- Store -->
      <section class="card">
        <h2>Choose Store</h2>
        <select name="storeID" id="storeID" required>
          <option value="">-- Select Store --</option>
          <cfoutput query="qStores">
            <option value="#StoreID#">#encodeForHTML(RegionName)# — #encodeForHTML(StoreName)#</option>
          </cfoutput>
        </select>
        <div class="muted">Pick your preferred branch.</div>
      </section>

      <!-- Service -->
      <section class="card">
        <h2>Choose Your Service Type</h2>
        <div class="service-grid" id="serviceGrid">
          <div class="service-box active" data-type="StoreDrop">
            <div class="service-emoji">🏪</div>
            <strong>Store Drop-off</strong>
            <small>Drop off and pickup at our nearest store.</small>
          </div>
          <div class="service-box" data-type="DeliveryPickup">
            <div class="service-emoji">🚚</div>
            <strong>Delivery Pickup</strong>
            <small>We pick up and deliver right to your door.</small>
          </div>
        </div>
        <input type="radio" name="dropType" value="StoreDrop" checked hidden>
        <input type="radio" name="dropType" value="DeliveryPickup" hidden>
      </section>

      <!-- Items -->
      <section class="card">
        <h2>Add Laundry Items</h2>
        <div class="items">
          <div class="item-row" data-item="shirt">
            <div class="item-name">👕 Shirts</div>
            <div class="item-controls">
              <button type="button" class="btn-q" data-delta="-1">-</button>
              <input type="number" name="shirt" value="0" readonly class="qty">
              <button type="button" class="btn-q" data-delta="1">+</button>
            </div>
          </div>

          <div class="item-row" data-item="pant">
            <div class="item-name">👖 Pants</div>
            <div class="item-controls">
              <button type="button" class="btn-q" data-delta="-1">-</button>
              <input type="number" name="pant" value="0" readonly class="qty">
              <button type="button" class="btn-q" data-delta="1">+</button>
            </div>
          </div>

          <div class="item-row" data-item="delicate">
            <div class="item-name">🧺 Delicates</div>
            <div class="item-controls">
              <button type="button" class="btn-q" data-delta="-1">-</button>
              <input type="number" name="delicate" value="0" readonly class="qty">
              <button type="button" class="btn-q" data-delta="1">+</button>
            </div>
          </div>

          <div class="item-row" data-item="bedding">
            <div class="item-name">🛏️ Bedding</div>
            <div class="item-controls">
              <button type="button" class="btn-q" data-delta="-1">-</button>
              <input type="number" name="bedding" value="0" readonly class="qty">
              <button type="button" class="btn-q" data-delta="1">+</button>
            </div>
          </div>

          <div class="item-row" data-item="towel">
            <div class="item-name">🧻 Towels</div>
            <div class="item-controls">
              <button type="button" class="btn-q" data-delta="-1">-</button>
              <input type="number" name="towel" value="0" readonly class="qty">
              <button type="button" class="btn-q" data-delta="1">+</button>
            </div>
          </div>
        </div>
      </section>

      <!-- Address (Delivery only) -->
      <section class="card" id="addressCard" style="display:none;">
        <h2>Delivery Address</h2>
        <input type="text" name="deliveryAddress" placeholder="Enter delivery address">
        <div class="muted">Required for Delivery Pickup.</div>
      </section>

      <!-- Summary -->
      <section class="card">
        <h2 style="text-align:center;">Order Summary</h2>
        <div class="summary-row"><span>Item Total</span> <strong><span id="itemTotal">₹0.00</span></strong></div>
        <div class="summary-row"><span>Service Fee</span> <span id="serviceFee">₹0.00</span></div>
        <div class="summary-row"><span>Delivery Fee</span> <span id="deliveryFee">₹0.00</span></div>
        <div class="total">
          <span>Total Estimated Price</span>
          <span id="totalPrice">₹0.00</span>
        </div>
      </section>

      <input type="hidden" name="__keep_fields_as_is" value="1">
    </form>
  </div>

  <!-- Sticky Confirm Bar -->
  <div class="confirm-bar">
    <div class="confirm-inner">
      <div class="pill">Items: <span id="pillItems" style="margin-left:6px; font-weight:800;">0</span></div>
      <div class="pill">Est. Total: <span id="pillTotal" style="margin-left:6px; font-weight:800;">₹0.00</span></div>
      <button type="submit" form="orderForm" id="btnConfirm" class="btn-primary" disabled>
        Confirm Booking
      </button>
    </div>
  </div>

  <script>
    // Pricing map (must match backend OrderService.cfc)
    const itemPrices = { shirt:10, pant:10, towel:10, delicate:5, bedding:20 };
    const serviceFeeFixed = 5;
    const deliveryFeeFixed = 20;

    const fmtINR = new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR', maximumFractionDigits: 2 });

    // Service selection
    const grid = document.getElementById('serviceGrid');
    const radios = document.querySelectorAll('input[name="dropType"]');
    const addressCard = document.getElementById('addressCard');

    grid.addEventListener('click', (e)=>{
      const box = e.target.closest('.service-box');
      if(!box) return;
      document.querySelectorAll('.service-box').forEach(b=>b.classList.remove('active'));
      box.classList.add('active');
      const type = box.getAttribute('data-type');
      radios.forEach(r => r.checked = (r.value === type));
      addressCard.style.display = (type === 'DeliveryPickup') ? 'block' : 'none';
      updatePrices();
      validate();
    });

    // Quantity controls
    document.querySelectorAll('.item-row').forEach(row=>{
      row.addEventListener('click', (e)=>{
        const btn = e.target.closest('.btn-q');
        if(!btn) return;
        const input = row.querySelector('input.qty');
        let v = parseInt(input.value || '0',10) + parseInt(btn.dataset.delta,10);
        if(v < 0) v = 0;
        input.value = v;
        updatePrices();
        validate();
      });
    });

    function updatePrices(){
      let itemsCount = 0;
      let itemTotal  = 0;

      for(const item in itemPrices){
        const qty = parseInt(document.querySelector(`input[name="${item}"]`).value || '0',10);
        if(qty > 0){
          itemsCount += qty;
          itemTotal  += qty * itemPrices[item];
        }
      }

      const isDelivery = Array.from(radios).some(r => r.checked && r.value === 'DeliveryPickup');
      const delivery   = isDelivery ? deliveryFeeFixed : 0;
      const total      = itemTotal + serviceFeeFixed + delivery;

      document.getElementById('itemTotal').innerText  = fmtINR.format(itemTotal);
      document.getElementById('serviceFee').innerText = fmtINR.format(serviceFeeFixed);
      document.getElementById('deliveryFee').innerText= fmtINR.format(delivery);
      document.getElementById('totalPrice').innerText = fmtINR.format(total);

      document.getElementById('pillItems').innerText  = itemsCount;
      document.getElementById('pillTotal').innerText  = fmtINR.format(total);
    }

    function validate(){
      const storeOK = !!document.getElementById('storeID').value;
      let itemsCount = 0;
      for(const item in itemPrices){
        itemsCount += parseInt(document.querySelector(`input[name="${item}"]`).value || '0',10);
      }
      const isDelivery = Array.from(radios).some(r => r.checked && r.value === 'DeliveryPickup');
      const addrOK = !isDelivery || (document.querySelector('input[name="deliveryAddress"]')?.value.trim().length >= 5);

      document.getElementById('btnConfirm').disabled = !(storeOK && itemsCount > 0 && addrOK);
    }

    document.getElementById('storeID').addEventListener('change', validate);
    document.addEventListener('input', (e)=>{ if(e.target.name === 'deliveryAddress'){ validate(); } });

    // Initial
    updatePrices(); validate();
  </script>

</body>
</html>
