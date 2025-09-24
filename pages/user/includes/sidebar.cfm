<!-- Sidebar -->
<div class="sidebar">
  <nav class="sidebar-nav">
    <a href="/laundryservice/index.cfm?fuse=admin_dashboard">🏠 Dashboard</a>
    <a href="/laundryservice/index.cfm?fuse=bookorder">🧺 Book Order</a>
    <a href="/laundryservice/index.cfm?fuse=orderhistory">📄 Order History</a>
    <a href="/laundryservice/index.cfm?fuse=agent_profile">👤 Profile</a>
    <a href="/laundryservice/index.cfm?fuse=admin_logout">🚪 Logout</a>
  </nav>
</div>

<style>
  .sidebar {
    width: 220px;
    height: 100vh;
    position: fixed;
    top: 0;
    left: 0;
    background: #fff;
    border-right: 1px solid #ddd;
    padding: 2rem 1rem;
    box-shadow: 2px 0 5px rgba(0, 0, 0, 0.05);
  }

  .sidebar-nav {
    display: flex;
    flex-direction: column;
    gap: 1rem;
    font-size: 1rem;
  }

  .sidebar-nav a {
    text-decoration: none;
    color: #333;
    font-weight: 500;
    padding: 0.5rem;
    border-radius: 6px;
    transition: background 0.2s ease, color 0.2s ease;
  }

  .sidebar-nav a:hover {
    background: #f5f5f5;
    color: #000;
  }

  .sidebar-nav a.active {
    background: #007bff;
    color: #fff;
  }
</style>
