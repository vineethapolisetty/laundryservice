// Scripts extracted for laundryservice/pages/user/payment_add.cfm
// Basic helpers
  const brandHint = document.getElementById('brandHint');
  const numEl = document.getElementById('cardNumber');
  const expEl = document.getElementById('exp');
  const cvvEl = document.getElementById('cvv');

  numEl.addEventListener('input', () => {
    let v = numEl.value.replace(/\D/g,'');
    // spacing
    numEl.value = v.replace(/(.{4})/g,'$1 ').trim();
    // detect brand
    const brand = detectBrand(v);
    brandHint.textContent = brand ? `(${brand})` : '';
  });

  expEl.addEventListener('input', () => {
    let v = expEl.value.replace(/\D/g,'');
    if(v.length >= 3){
      v = v.slice(0,4);
      expEl.value = v.slice(0,2) + '/' + v.slice(2);
    }else{
      expEl.value = v;
    }
  });

  function detectBrand(digits){
    if(/^4/.test(digits)) return 'Visa';
    if(/^(5[1-5]|2(2[2-9]|[3-6]\d|7[01]|720))/.test(digits)) return 'Mastercard';
    if(/^3[47]/.test(digits)) return 'Amex';
    if(/^6(011|5)/.test(digits)) return 'Discover';
    return '';
  }

  function luhnValid(num){
    let sum=0, dbl=false;
    for(let i=num.length-1;i>=0;i--){
      let d = parseInt(num[i],10);
      if(dbl){ d*=2; if(d>9) d-=9; }
      sum += d; dbl = !dbl;
    }
    return sum % 10 === 0;
  }

  function tokenizeAndSubmit(){
    const name = document.getElementById('cardName').value.trim();
    const num  = numEl.value.replace(/\D/g,'');
    const exp  = expEl.value.replace(/\s/g,'');
    const cvv  = cvvEl.value.replace(/\D/g,'');

    // Basic checks
    if(!name) { alert('Enter cardholder name'); return false; }
    if(num.length < 12 || num.length > 19 || !luhnValid(num)){ alert('Enter a valid card number'); return false; }
    if(!/^\d{2}\/\d{2}$/.test(exp)){ alert('Enter expiry as MM/YY'); return false; }

    const mm = parseInt(exp.slice(0,2),10);
    const yy = parseInt('20' + exp.slice(3),10);
    if(mm<1 || mm>12){ alert('Invalid expiry month'); return false; }
    const now = new Date(), cm = now.getMonth()+1, cy = now.getFullYear();
    if(yy < cy || (yy===cy && mm < cm)){ alert('Card is expired'); return false; }
    if(cvv.length < 3 || cvv.length > 4){ alert('Invalid CVV'); return false; }

    // Simulated token (replace with real gateway tokenization in production)
    const brand = detectBrand(num) || 'Card';
    const token = 'tok_' + Math.random().toString(36).slice(2) + Date.now().toString(36);

    // Fill hidden fields; DO NOT send PAN/CVV
    document.getElementById('hidToken').value    = token;
    document.getElementById('hidBrand').value    = brand;
    document.getElementById('hidLast4').value    = num.slice(-4);
    document.getElementById('hidExpMonth').value = String(mm);
    document.getElementById('hidExpYear').value  = String(yy);
    document.getElementById('hidIsDefault').value= document.getElementById('makeDefault').checked ? '1' : '0';

    // Clear sensitive fields before submit
    numEl.value = '';
    expEl.value = '';
    cvvEl.value = '';

    return true; // submit
  }