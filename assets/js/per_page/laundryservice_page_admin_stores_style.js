// Scripts extracted for laundryservice/pages/admin/stores.cfm
function editStore(id, name, regionID, address) {
      document.getElementById('editStoreID').value = id;
      document.getElementById('editStoreName').value = name;
      document.getElementById('editRegionID').value = regionID;
      document.getElementById('editAddress').value = address;
      new bootstrap.Modal(document.getElementById('editStoreModal')).show();
    }