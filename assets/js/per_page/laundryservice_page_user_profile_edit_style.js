// Scripts extracted for laundryservice/pages/user/profile_edit.cfm
function validateForm(){
    const name = document.getElementById('fullName').value.trim();
    const email= document.getElementById('email').value.trim();
    const phone= document.getElementById('phone').value.trim();
    if(!name){ alert('Name is required'); return false; }
    if(email && !/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)){ alert('Enter a valid email'); return false; }
    if(phone && !/^[0-9+\-\s()]{7,}$/.test(phone)){ alert('Enter a valid phone'); return false; }
    return true;
  }