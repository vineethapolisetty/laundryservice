// Scripts extracted for laundryservice/pages/user/bookOrder.cfm
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