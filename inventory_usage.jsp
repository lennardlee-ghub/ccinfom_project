<%@page import="java.sql.*" %>

<%
   
    int inv_usg_id_edit = 0;
    int dr_id_edit = 0;
    int inv_id_edit = 0;
    String item_name_edit = "";
    int quantity_used_edit = 0;
    String date_used_edit = "";
    String category_edit = "";

  
    String action = request.getParameter("action");

        if("insert".equals(action))
    {
        
        int dr_id = Integer.parseInt(request.getParameter("dr_id_add"));
        int inv_id = Integer.parseInt(request.getParameter("inv_id_add"));
        String quantityStr = request.getParameter("quantity_used_add");
        quantityStr = quantityStr.replaceAll(",", "");
        int quantity_used = Integer.parseInt(quantityStr);
        String date_used = request.getParameter("date_used_add");
        String category = request.getParameter("category_add");

        Connection con = null;
        PreparedStatement pst = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project", "root", "ccinfomgoat9");
            
            // Start transaction
            con.setAutoCommit(false);
            
            
            pst = con.prepareStatement("SELECT quantity FROM inventory_core WHERE inv_id = ?");
            pst.setInt(1, inv_id);
            rs = pst.executeQuery();
            
            int available_quantity = 0;
            if(rs.next()) {
                available_quantity = rs.getInt("quantity");
            }
            
            if(available_quantity < quantity_used) {
              
                con.rollback();
                %>
                <script>
                    alert('Error: Insufficient inventory. Available: <%= available_quantity %>, Requested: <%= quantity_used %>');
                    window.location.href = 'inventory_usage.jsp';
                </script>
                <%
            } else {
                // Insert usage record (derived from damage_repair)
                pst = con.prepareStatement("INSERT INTO inventory_usage(dr_id, inv_id, quantity_used, date_used, category) VALUES(?,?,?,?,?)");
                pst.setInt(1, dr_id);
                pst.setInt(2, inv_id);
                pst.setInt(3, quantity_used);
                pst.setString(4, date_used);
                pst.setString(5, category);
                pst.executeUpdate();
                
                // Update the inventory core thing cause u dont wannt the goofy stuff - deduct the quantity
                pst = con.prepareStatement("UPDATE inventory_core SET quantity = quantity - ? WHERE inv_id = ?");
                pst.setInt(1, quantity_used);
                pst.setInt(2, inv_id);
                pst.executeUpdate();
                
                con.commit();
                response.sendRedirect("inventory_usage.jsp");
            }
        } catch(Exception e) {
            if(con != null) con.rollback();
            e.printStackTrace();
        } finally {
            if(rs != null) rs.close();
            if(pst != null) pst.close();
            if(con != null) {
                con.setAutoCommit(true);
                con.close();
            }
        }
    }
    else if("getEdit".equals(action))
    {
        int inv_usg_id = Integer.parseInt(request.getParameter("inv_usg_id"));

        Connection con = null;
        PreparedStatement pst = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
            pst = con.prepareStatement("SELECT iu.*, ic.item_name FROM inventory_usage iu JOIN inventory_core ic ON iu.inv_id = ic.inv_id WHERE iu.inv_usg_id = ?");
            pst.setInt(1, inv_usg_id);
            rs = pst.executeQuery();

            if(rs.next())
            {
                inv_usg_id_edit = rs.getInt("inv_usg_id");
                dr_id_edit = rs.getInt("dr_id");
                inv_id_edit = rs.getInt("inv_id");
                item_name_edit = rs.getString("item_name");
                quantity_used_edit = rs.getInt("quantity_used");
                date_used_edit = rs.getString("date_used");
                category_edit = rs.getString("category");
            }
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            if(rs != null) rs.close();
            if(pst != null) pst.close();
            if(con != null) con.close();
        }
        %>
        <script>
            window.onload = function()
            {
                var editModal = new bootstrap.Modal(document.getElementById('editModal'));
                editModal.show();
            };
        </script>
        <%
    }
    else if("submitEdit".equals(action))
    {
        int inv_usg_id = Integer.parseInt(request.getParameter("inv_usg_id_edit"));
        int dr_id = Integer.parseInt(request.getParameter("dr_id_edit"));
        int inv_id = Integer.parseInt(request.getParameter("inv_id_edit"));
        String quantityStr = request.getParameter("quantity_used_edit");
        quantityStr = quantityStr.replaceAll(",", "");
        int new_quantity_used = Integer.parseInt(quantityStr);
        String date_used = request.getParameter("date_used_edit");
        String category = request.getParameter("category_edit");

        Connection con = null;
        PreparedStatement pst = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
            con.setAutoCommit(false);
            
           
            pst = con.prepareStatement("SELECT quantity_used FROM inventory_usage WHERE inv_usg_id = ?");
            pst.setInt(1, inv_usg_id);
            rs = pst.executeQuery();
            
            int old_quantity_used = 0;
            if(rs.next()) {
                old_quantity_used = rs.getInt("quantity_used");
            }
            
            
            int quantity_difference = new_quantity_used - old_quantity_used;
            
           
            if(quantity_difference > 0) {
                pst = con.prepareStatement("SELECT quantity FROM inventory_core WHERE inv_id = ?");
                pst.setInt(1, inv_id);
                rs = pst.executeQuery();
                
                int available_quantity = 0;
                if(rs.next()) {
                    available_quantity = rs.getInt("quantity");
                }
                
                if(available_quantity < quantity_difference) {
                    con.rollback();
                    %>
                    <script>
                        alert('Error: Insufficient inventory for this update.');
                        window.location.href = 'inventory_usage.jsp';
                    </script>
                    <%
                    return;
                }
            }
            
          
            pst = con.prepareStatement("UPDATE inventory_usage SET dr_id=?, inv_id=?, quantity_used=?, date_used=?, category=? WHERE inv_usg_id=?");
            pst.setInt(1, dr_id);
            pst.setInt(2, inv_id);
            pst.setInt(3, new_quantity_used);
            pst.setString(4, date_used);
            pst.setString(5, category);
            pst.setInt(6, inv_usg_id);
            pst.executeUpdate();
            
            // Adjust inventory (subtract the difference)
            pst = con.prepareStatement("UPDATE inventory_core SET quantity = quantity - ? WHERE inv_id = ?");
            pst.setInt(1, quantity_difference);
            pst.setInt(2, inv_id);
            pst.executeUpdate();
            
            con.commit();
            response.sendRedirect("inventory_usage.jsp");
        } catch(Exception e) {
            if(con != null) con.rollback();
            e.printStackTrace();
        } finally {
            if(rs != null) rs.close();
            if(pst != null) pst.close();
            if(con != null) {
                con.setAutoCommit(true);
                con.close();
            }
        }
    }
    else if("delete".equals(action))
    {
        int inv_usg_id = Integer.parseInt(request.getParameter("inv_usg_id"));

        Connection con = null;
        PreparedStatement pst = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
            con.setAutoCommit(false);
            
            
            pst = con.prepareStatement("SELECT inv_id, quantity_used FROM inventory_usage WHERE inv_usg_id = ?");
            pst.setInt(1, inv_usg_id);
            rs = pst.executeQuery();
            
            int inv_id = 0;
            int quantity_used = 0;
            if(rs.next()) {
                inv_id = rs.getInt("inv_id");
                quantity_used = rs.getInt("quantity_used");
            }
            
            
            pst = con.prepareStatement("DELETE FROM inventory_usage WHERE inv_usg_id = ?");
            pst.setInt(1, inv_usg_id);
            pst.executeUpdate();
            
           
            pst = con.prepareStatement("UPDATE inventory_core SET quantity = quantity + ? WHERE inv_id = ?");
            pst.setInt(1, quantity_used);
            pst.setInt(2, inv_id);
            pst.executeUpdate();
            
            con.commit();
            response.sendRedirect("inventory_usage.jsp");
        } catch(Exception e) {
            if(con != null) con.rollback();
            e.printStackTrace();
        } finally {
            if(rs != null) rs.close();
            if(pst != null) pst.close();
            if(con != null) {
                con.setAutoCommit(true);
                con.close();
            }
        }
    }
%>

<html style="overflow:hidden">
    <head>
        <style>
            html, body{
                margin: 0;
                padding: 0;
            }
            ul li {
                margin-bottom: 17px;
            }
        </style>
        <script src="bootstrap-5.2.3-dist/js/bootstrap.bundle.js"></script>
        <link rel="stylesheet" href="bootstrap-5.2.3-dist/css/bootstrap.css">
    </head>

    <body style="overflow:hidden">
        <table style="overflow:none">
            <tr>
                <td>
                    <jsp:include page="/sidebar.jsp" />
                </td>

                <td style="width:calc(100vw - 350px)" class="d-flex align-items-center">
                    <div style="width:100%;display:flex;justify-content:center;flex-direction: column;align-items:center">
                        <div class="d-flex" style="width:90%;margin-top:40px">
                            <div style="font-family:arial;font-size:28px;">
                                Inventory Usage Records
                            </div>
                            <button class="btn btn-success fw-bold" type="button" style="margin-left:auto" data-bs-toggle="modal" data-bs-target="#addModal">
                                Record Usage
                            </button>
                        </div>

                        <div style="width:100%;display:flex;justify-content:center;margin-top:20px;overflow-y:auto;max-height:calc(100vh - 150px)">
                            <table class="table table-striped" style='width:90%'>
                                <thead>
                                    <tr>
                                        <td class="fw-bold">Usage ID</td>
                                        <td class="fw-bold">Damage Repair Info</td>
                                        <td class="fw-bold">Item Used</td>
                                        <td class="fw-bold">Category</td>
                                        <td class="fw-bold">Quantity Used</td>
                                        <td class="fw-bold">Date Used</td>
                                        <td class="fw-bold">Action</td>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        Connection con = null;
                                        Statement st = null;
                                        ResultSet rs = null;

                                        try {
                                            Class.forName("com.mysql.jdbc.Driver");
                                            con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");

                                            String query = "SELECT iu.*, ic.item_name, ic.unit_of_measurement, inf.type_of_infra, inf.location FROM inventory_usage iu " +
                                                         "JOIN inventory_core ic ON iu.inv_id = ic.inv_id " +
                                                         "LEFT JOIN damage_repair dr ON iu.dr_id = dr.dr_id " +
                                                         "LEFT JOIN damage_recording_infra dri ON dr.dri_id = dri.dri_id " +
                                                         "LEFT JOIN infrastructure_core inf ON dri.inf_id = inf.inf_id " +
                                                         "ORDER BY iu.date_used DESC, iu.inv_usg_id DESC";
                                            st = con.createStatement();
                                            rs = st.executeQuery(query);

                                            while(rs.next())
                                            {
                                                int inv_usg_id = rs.getInt("inv_usg_id");
                                    %>
                                    <tr>
                                        <td><%=inv_usg_id%></td>
                                        <td><%=
                                            (rs.getString("type_of_infra") != null ? rs.getString("type_of_infra") + " - " + rs.getString("location") : "N/A")
                                        %></td>
                                        <td><%=rs.getString("item_name")%></td>
                                        <td><%=rs.getString("category")%></td>
                                        <td><%=rs.getInt("quantity_used")%> <%=rs.getString("unit_of_measurement")%></td>
                                        <td><%=rs.getString("date_used")%></td>
                                        <td>
                                            <div class="dropdown text-center">
                                                <button class="btn btn-primary fw-bold" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                                                    Action
                                                </button>
                                                <ul class="dropdown-menu">
                                                    <li><a class="dropdown-item" href="inventory_usage.jsp?action=getEdit&inv_usg_id=<%= inv_usg_id %>">Edit</a></li>
                                                    <li><a class="dropdown-item" href="inventory_usage.jsp?action=delete&inv_usg_id=<%= inv_usg_id %>" onclick="return confirm('Are you sure you want to delete this usage record? This will restore the inventory quantity.');">Delete</a></li>
                                                </ul>
                                            </div>
                                        </td>
                                    </tr>
                                    <%
                                            }
                                        } catch(Exception e) {
                                            e.printStackTrace();
                                        } finally {
                                            if(rs != null) rs.close();
                                            if(st != null) st.close();
                                            if(con != null) con.close();
                                        }
                                    %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </td>
            </tr>
        </table>

        <!-- Add Modal -->
        <div class="modal fade" id="addModal" tabindex="-1" aria-labelledby="addModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h1 class="modal-title fs-5" id="addModalLabel">Record Inventory Usage</h1>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <form action="inventory_usage.jsp" method="POST">
                            <input type="hidden" name="action" value="insert">
                            <div class="mb-3">
                                <label for="dr_id_add" class="form-label">Damage Repair Record</label>
                                <select class="form-select" id="dr_id_add" name="dr_id_add" required>
                                    <option value="">Select Damage Repair...</option>
                                    <%
                                        Connection con2 = null;
                                        Statement st2 = null;
                                        ResultSet rs2 = null;
                                        try {
                                            Class.forName("com.mysql.jdbc.Driver");
                                            con2 = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
                                            String query2 = "SELECT dr.dr_id, dr.status, dri.damage_details, inf.location " +
                                                          "FROM damage_repair dr " +
                                                          "JOIN damage_recording_infra dri ON dr.dri_id = dri.dri_id " +
                                                          "JOIN infrastructure_core inf ON dri.inf_id = inf.inf_id " +
                                                          "ORDER BY dr.dr_id DESC";
                                            st2 = con2.createStatement();
                                            rs2 = st2.executeQuery(query2);
                                            while(rs2.next()) {
                                    %>
                                    <option value="<%=rs2.getInt("dr_id")%>">
                                        DR-<%=rs2.getInt("dr_id")%> | <%=rs2.getString("damage_details")%> - <%=rs2.getString("location")%> (<%=rs2.getString("status")%>)
                                    </option>
                                    <%
                                            }
                                        } catch(Exception e) {
                                            e.printStackTrace();
                                        } finally {
                                            if(rs2 != null) rs2.close();
                                            if(st2 != null) st2.close();
                                            if(con2 != null) con2.close();
                                        }
                                    %>
                                </select>
                            </div>
                            
                            <div class="mb-3">
                                <label for="inv_id_add" class="form-label">Inventory Item</label>
                                <select class="form-select" id="inv_id_add" name="inv_id_add" required>
                                    <option value="">Select Item...</option>
                                    <%
                                        Connection con4 = null;
                                        Statement st4 = null;
                                        ResultSet rs4 = null;
                                        try {
                                            Class.forName("com.mysql.jdbc.Driver");
                                            con4 = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
                                            String query4 = "SELECT inv_id, item_name, quantity, type_of_inventory, unit_of_measurement FROM inventory_core ORDER BY item_name";
                                            st4 = con4.createStatement();
                                            rs4 = st4.executeQuery(query4);
                                            while(rs4.next()) {
                                    %>
                                    <option value="<%=rs4.getInt("inv_id")%>" data-available="<%=rs4.getInt("quantity")%>">
                                        <%=rs4.getString("item_name")%> - <%=rs4.getString("type_of_inventory")%> (<%=rs4.getInt("quantity")%> <%=rs4.getString("unit_of_measurement")%> available)
                                    </option>
                                    <%
                                            }
                                        } catch(Exception e) {
                                            e.printStackTrace();
                                        } finally {
                                            if(rs4 != null) rs4.close();
                                            if(st4 != null) st4.close();
                                            if(con4 != null) con4.close();
                                        }
                                    %>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label for="category_add" class="form-label">Category</label>
                                <select class="form-select" id="category_add" name="category_add" required>
                                    <option value="General Repairs">General Repairs</option>
                                    <option value="Plumbing">Plumbing</option>
                                    <option value="Electrical">Electrical</option>
                                    <option value="Other">Other</option>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label for="quantity_used_add" class="form-label">Quantity Used</label>
                                <input type="number" class="form-control" id="quantity_used_add" name="quantity_used_add" required min="1">
                                <div id="quantity_error_add" class="form-text text-danger" style="display:none"></div>
                            </div>
                            <div class="mb-3">
                                <label for="date_used_add" class="form-label">Date Used</label>
                                <input type="date" class="form-control" id="date_used_add" name="date_used_add" required>
                            </div>
                            <button type="submit" class="btn btn-primary">Submit</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <!-- Edit Modal -->
        <div class="modal fade" id="editModal" tabindex="-1" aria-labelledby="editModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h1 class="modal-title fs-5" id="editModalLabel">Edit Inventory Usage</h1>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <form action="inventory_usage.jsp" method="POST">
                            <input type="hidden" name="action" value="submitEdit">
                            <input type="hidden" name="inv_usg_id_edit" value="<%= inv_usg_id_edit %>">
                            <div class="mb-3">
                                <label for="dr_id_edit" class="form-label">Damage Repair Record</label>
                                <select class="form-select" id="dr_id_edit" name="dr_id_edit" required>
                                    <%
                                        Connection con5 = null;
                                        Statement st5 = null;
                                        ResultSet rs5 = null;
                                        try {
                                            Class.forName("com.mysql.jdbc.Driver");
                                            con5 = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
                                            String query5 = "SELECT dr.dr_id, dr.status, dri.damage_details, inf.location " +
                                                          "FROM damage_repair dr " +
                                                          "JOIN damage_recording_infra dri ON dr.dri_id = dri.dri_id " +
                                                          "JOIN infrastructure_core inf ON dri.inf_id = inf.inf_id " +
                                                          "ORDER BY dr.dr_id DESC";
                                            st5 = con5.createStatement();
                                            rs5 = st5.executeQuery(query5);
                                            while(rs5.next()) {
                                                int dr_id_option = rs5.getInt("dr_id");
                                    %>
                                    <option value="<%=dr_id_option%>" <%= dr_id_option == dr_id_edit ? "selected" : "" %>>
                                        DR-<%=dr_id_option%> | <%=rs5.getString("damage_details")%> - <%=rs5.getString("location")%> (<%=rs5.getString("status")%>)
                                    </option>
                                    <%
                                            }
                                        } catch(Exception e) {
                                            e.printStackTrace();
                                        } finally {
                                            if(rs5 != null) rs5.close();
                                            if(st5 != null) st5.close();
                                            if(con5 != null) con5.close();
                                        }
                                    %>
                                </select>
                            </div>
                            
                            <div class="mb-3">
                                <label for="inv_id_edit" class="form-label">Inventory Item</label>
                                <select class="form-select" id="inv_id_edit" name="inv_id_edit" required>
                                    <%
                                        Connection con7 = null;
                                        Statement st7 = null;
                                        ResultSet rs7 = null;
                                        try {
                                            Class.forName("com.mysql.jdbc.Driver");
                                            con7 = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
                                            String query7 = "SELECT inv_id, item_name, quantity, type_of_inventory, unit_of_measurement FROM inventory_core ORDER BY item_name";
                                            st7 = con7.createStatement();
                                            rs7 = st7.executeQuery(query7);
                                            while(rs7.next()) {
                                                int inv_id_option = rs7.getInt("inv_id");
                                    %>
                                    <option value="<%=inv_id_option%>" data-available="<%=rs7.getInt("quantity")%>" <%= inv_id_option == inv_id_edit ? "selected" : "" %>>
                                        <%=rs7.getString("item_name")%> - <%=rs7.getString("type_of_inventory")%> (<%=rs7.getInt("quantity")%> <%=rs7.getString("unit_of_measurement")%> available)
                                    </option>
                                    <%
                                            }
                                                                                } catch(Exception e) {
                                            e.printStackTrace();
                                        } finally {
                                            if(rs7 != null) rs7.close();
                                            if(st7 != null) st7.close();
                                            if(con7 != null) con7.close();
                                        }
                                    %>
                                </select>
                            </div>

                            <div class="mb-3">
                                <label for="category_edit" class="form-label">Category</label>
                                <select class="form-select" id="category_edit" name="category_edit" required>
                                    <option value="General Repairs" <%= "General Repairs".equals(category_edit) ? "selected" : "" %>>General Repairs</option>
                                    <option value="Plumbing" <%= "Plumbing".equals(category_edit) ? "selected" : "" %>>Plumbing</option>
                                    <option value="Electrical" <%= "Electrical".equals(category_edit) ? "selected" : "" %>>Electrical</option>
                                    <option value="Other" <%= "Other".equals(category_edit) ? "selected" : "" %>>Other</option>
                                </select>
                            </div>

                            <div class="mb-3">
                                <label for="quantity_used_edit" class="form-label">Quantity Used</label>
                                <input type="number" class="form-control" id="quantity_used_edit" 
                                    name="quantity_used_edit" min="1" 
                                    value="<%= quantity_used_edit %>" required>
                                <div id="quantity_error_edit" class="form-text text-danger" style="display:none"></div>
                            </div>

                            <div class="mb-3">
                                <label for="date_used_edit" class="form-label">Date Used</label>
                                <input type="date" class="form-control" id="date_used_edit" 
                                       name="date_used_edit" 
                                       value="<%= date_used_edit %>" required>
                            </div>

                            <button type="submit" class="btn btn-primary">Save Changes</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>

    </body>
    <script>
        function getSelectedAvailable(selectEl) {
            var opt = selectEl.options[selectEl.selectedIndex];
            if(!opt) return 0;
            var a = opt.getAttribute('data-available');
            return a ? parseInt(a,10) : 0;
        }

        function showError(elId, msg) {
            var el = document.getElementById(elId);
            if(!el) return;
            el.style.display = msg ? 'block' : 'none';
            el.textContent = msg || '';
        }

        function validateInventoryUsage(form, isEdit) {
            var invSelect = form.querySelector(isEdit ? '#inv_id_edit' : '#inv_id_add');
            var qtyInput = form.querySelector(isEdit ? '#quantity_used_edit' : '#quantity_used_add');
            // Require item selection first cause why not bruhhh im cryinn bruhhh why is sql tripping
            if(!invSelect || !invSelect.value) {
                showError(isEdit ? 'quantity_error_edit' : 'quantity_error_add', 'Please select an inventory item first.');
                if(invSelect) invSelect.focus();
                return false;
            }
            var available = getSelectedAvailable(invSelect);
            var requested = parseInt(qtyInput.value || '0', 10);

            if(isEdit) {
                var original = parseInt(qtyInput.getAttribute('data-original') || '0', 10);
                var allowed = available + original;
                if(requested > allowed) {
                    showError(isEdit ? 'quantity_error_edit' : 'quantity_error_add', 'Insufficient inventory: available ' + available + ' (you currently used ' + original + '), requested ' + requested + '.');
                    return false;
                }
            } else {
                if(requested > available) {
                    showError(isEdit ? 'quantity_error_edit' : 'quantity_error_add', 'Insufficient inventory: available ' + available + ', requested ' + requested + '.');
                    return false;
                }
            }

            showError(isEdit ? 'quantity_error_edit' : 'quantity_error_add', '');
            return true;
        }

       
        document.addEventListener('DOMContentLoaded', function() {
            var addForm = document.querySelector('form[action="inventory_usage.jsp"][method="POST"]');
            if(addForm) {
                addForm.addEventListener('submit', function(e){
                    var actionInput = addForm.querySelector('input[name="action"]');
                    if(actionInput && actionInput.value === 'insert') {
                        if(!validateInventoryUsage(addForm, false)) {
                            e.preventDefault();
                        }
                    }
                });

                var qtyAdd = document.getElementById('quantity_used_add');
                var invAdd = document.getElementById('inv_id_add');
                if(qtyAdd && invAdd) {
                   
                    qtyAdd.disabled = !invAdd.value;

                    qtyAdd.addEventListener('focus', function(){ if(this.disabled){ showError('quantity_error_add','Please select an inventory item first.'); invAdd.focus(); } });

                    qtyAdd.addEventListener('input', function(){ validateInventoryUsage(addForm, false); });
                    invAdd.addEventListener('change', function(){
                        qtyAdd.disabled = !invAdd.value;
                        if(invAdd.value) {
                            showError('quantity_error_add','');
                        } else {
                            showError('quantity_error_add','Please select an inventory item first.');
                        }
                    });
                }
            }

            var editForm = null;
            var forms = document.querySelectorAll('form[action="inventory_usage.jsp"][method="POST"]');
            for(var i=0;i<forms.length;i++){
                var ai = forms[i].querySelector('input[name="action"]');
                if(ai && ai.value === 'submitEdit') { editForm = forms[i]; break; }
            }
            if(editForm) {
                var qtyEdit = document.getElementById('quantity_used_edit');
                if(qtyEdit) {
                    qtyEdit.setAttribute('data-original', '<%= quantity_used_edit %>');
                }

                editForm.addEventListener('submit', function(e){
                    if(!validateInventoryUsage(editForm, true)) {
                        e.preventDefault();
                    }
                });

                var invEdit = document.getElementById('inv_id_edit');
                if(qtyEdit && invEdit) {
                    qtyEdit.disabled = !invEdit.value;

                    qtyEdit.addEventListener('focus', function(){ if(this.disabled){ showError('quantity_error_edit','Please select an inventory item first.'); invEdit.focus(); } });

                    qtyEdit.addEventListener('input', function(){ validateInventoryUsage(editForm, true); });
                    invEdit.addEventListener('change', function(){
                        qtyEdit.disabled = !invEdit.value;
                        if(invEdit.value) showError('quantity_error_edit',''); else showError('quantity_error_edit','Please select an inventory item first.');
                    });
                }
            }
        });
    </script>
</html>
