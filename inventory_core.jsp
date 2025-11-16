    
    <%@page import="java.sql.*" %>

    <%
        //global variables for editing
        String type_of_inventory_edit = "";
        String unit_of_measurement_edit = "";
        String category_edit = "";
        String item_name_edit = "";
        int  quantity_edit= 0;
        int inv_id_edit = 0;

        //for inserting a record logic
        String action = request.getParameter("action");

        if("insert".equals(action))
        {
            //insert variables
            String type_of_inventory_add = request.getParameter("type_of_inventory_add");
            String unit_of_measurement_add = request.getParameter("unit_of_measurement_add");
            String category_add= request.getParameter("category_add");
            String item_name_add= request.getParameter("item_name_add");
            String quantityStr = request.getParameter("quantity_add");
            quantityStr = quantityStr.replaceAll(",", "");
            int quantity_add = Integer.parseInt(quantityStr);

            //Connection
            Connection con;
            PreparedStatement pst;
            ResultSet rs;

            //Insert statement
            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project", "root", "ccinfomgoat9");
            pst = con.prepareStatement("INSERT INTO inventory_core(item_name, type_of_inventory, unit_of_measurement, category, quantity) VALUES(?,?,?,?,?)");
            pst.setString(1, item_name_add);
            pst.setString(2, type_of_inventory_add);
            pst.setString(3, unit_of_measurement_add);
            pst.setString(4, category_add);
            pst.setInt(5,quantity_add);
            pst.executeUpdate();
            response.sendRedirect("inventory_core.jsp");
        }
        else if("getEdit".equals(action))
        {
            //Getting the inv_id
            String inv_id_str = request.getParameter("inv_id");
            int inv_id = Integer.parseInt(inv_id_str);

            //Connection
            Connection con;
            PreparedStatement pst;
            ResultSet rs;

            //Get the table data
            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
            pst = con.prepareStatement("SELECT * FROM inventory_core WHERE inv_id=?");
            pst.setInt(1, inv_id);
            rs = pst.executeQuery();

            if(rs.next())
            {
                inv_id_edit = rs.getInt("inv_id");
                item_name_edit = rs.getString("item_name");
                type_of_inventory_edit = rs.getString("type_of_inventory");
                unit_of_measurement_edit = rs.getString("unit_of_measurement");
                category_edit =  rs.getString("category");
                quantity_edit = rs.getInt("quantity");
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
            //Get parameters from edit form
            int inv_id = Integer.parseInt(request.getParameter("inv_id_edit"));
            String type_of_inventory = request.getParameter("type_of_inventory_edit");
            String unit_of_measurement = request.getParameter("unit_of_measurement_edit");
            String category = request.getParameter("category_edit");
            String item_name = request.getParameter("item_name_edit");
            String quantityStr = request.getParameter("quantity_edit");
            quantityStr = quantityStr.replaceAll(",", "");
            int quantity = Integer.parseInt(quantityStr);

            //// Connection
            Connection con;
            PreparedStatement pst;

            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
            pst = con.prepareStatement("UPDATE inventory_core SET item_name=?, type_of_inventory=?, unit_of_measurement=?, category=?, quantity=? WHERE inv_id=?");
            pst.setString(1, item_name);
            pst.setString(2, type_of_inventory);
            pst.setString(3, unit_of_measurement);
            pst.setString(4, category);
            pst.setInt(5, quantity);
            pst.setInt(6, inv_id);
            pst.executeUpdate();
            response.sendRedirect("inventory_core.jsp");
        }
        else if("delete".equals(action))
        {
            //Get inv_id for deletion
            int inv_id = Integer.parseInt(request.getParameter("inv_id"));

            //Connection
            Connection con;
            PreparedStatement pst;

            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
            pst = con.prepareStatement("DELETE FROM inventory_core WHERE inv_id=?");
            pst.setInt(1, inv_id);
            pst.executeUpdate();
            response.sendRedirect("inventory_core.jsp");
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
                    margin-bottom: 17px; /* adds vertical spacing */
                }
            </style>
            <!-- for the popper js-->
            <script src="bootstrap-5.2.3-dist/js/bootstrap.bundle.js"></script>
            <!-- fir the css file-->
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
                            <div class="d-flex" style="width:80%;margin-top:40px">
                                <div style="font-family:arial;font-size:28px;font-family:arial">
                                    Inventory Records
                                </div>

                                <button class="btn btn-success fw-bold" type="button" style="margin-left:auto" data-bs-toggle="modal" data-bs-target="#addModal">
                                    Add Record
                                </button>
                            </div>

                            <div style="width:100%;display:flex;justify-content:center;margin-top:20px">
                                <table class="table table-striped" style='width:80%'>
                                    <thead>
                                        <tr>
                                            <td class="fw-bold">Item</td>
                                            <td class="fw-bold">Type of Inventory</td>
                                            <td class="fw-bold">Unit of Measurement</td>
                                            <td class="fw-bold">Category</td>
                                            <td class="fw-bold">Quantity</td>
                                            <td class="fw-bold">Action</td>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <%
                                            Connection con;
                                            PreparedStatement pst;
                                            ResultSet rs;

                                            Class.forName("com.mysql.jdbc.Driver");
                                            con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");

                                            String query = "SELECT * FROM inventory_core";
                                            Statement st = con.createStatement();
                                            rs = st.executeQuery(query);

                                            while(rs.next())
                                            {
                                                int inv_id = rs.getInt("inv_id");
                                        %>
                                        <tr> 
                                            <td><%=rs.getString("item_name")%></td>
                                            <td><%=rs.getString("type_of_inventory") %></td>
                                            <td><%=rs.getString("unit_of_measurement") %></td>
                                            <td><%=rs.getString("category") %></td>
                                            <td><%=rs.getInt("quantity")%></td>
                                            <td>
                                                <div class="dropdown text-center">
                                                    <button class="btn btn-primary fw-bold" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                                                        Action
                                                    </button>
                                                    <ul class="dropdown-menu">
                                                        <li><a class="dropdown-item" href="inventory_core.jsp?action=getEdit&inv_id=<%= inv_id %>">Edit</a></li>
                                                        <li><a class="dropdown-item" href="inventory_core.jsp?action=delete&inv_id=<%= inv_id %>" onclick="return confirm('Are you sure you want to delete this record?');">Delete</a></li> 
                                                    </ul>
                                                </div>
                                            </td>
                                        </tr>
                                        <%
                                            }
                                            con.close();
                                        %>
                                    </tbody>
                                </table>
                        </div>        
                    </td>
                </tr>
            </table>

            <!--Add Modal for inserting record-->
            <div class="modal fade" id="addModal" tabindex="-1" aria-labelledby="addModalLabel" aria-hidden="true">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h1 class="modal-title fs-5" id="addModalLabel">Add Inventory Record</h1>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <form action="inventory_core.jsp" method="POST">
                                <input type="hidden" name="action" value="insert">
                                <div class="mb-3">
                                    <label for="item_name_add" class="form-label">Item</label>
                                    <input type="text" class="form-control" id="item_name_add" name="item_name_add">
                                </div>
                                <div class="mb-3">
                                    <label for="type_of_inventory_add" class="form-label">Type of Inventory</label>
                                    <select class="form-select" id="type_of_inventory_add" name="type_of_inventory_add" onchange="checkOtherType(this)">
                                        <option value="Tools">Tools</option>
                                        <option value="Materials">Materials</option>
                                        <option value="Funds">Funds</option>
                                        <option value="Other">Other</option>                                        
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label for="unit_of_measurement_add" class="form-label">Unit of Measurement</label>
                                    <select class="form-select" id="unit_of_measurement_add" name="unit_of_measurement_add">
                                        <option value="Piece">Piece</option>
                                        <option value="Box">Box</option>
                                        <option value="Set">Set</option>
                                        <option value="Kilogram">Kilogram</option>
                                        <option value="Meter">Meter</option>
                                        <option value="Liter">Liter</option>
                                        <option value="PHP">PHP</option>
                                        <option value="Other">Other</option>                                       
                                    </select>
                                </div>  
                                <div class="mb-3">
                                    <label for="category_add" class="form-label">Category</label>
                                    <select class="form-select" id="category_add" name="category_add">
                                        <option value="General Repairs">General Repairs</option>
                                        <option value="Plumbing">Plumbing</option>
                                        <option value="Electrical">Electrical</option>
                                        <option value="Other">Other</option>                                      
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label for="quantity_add" class="form-label">Quantity</label>
                                    <input type="text" class="form-control" id="quantity_add" name="quantity_add">
                                </div>
                                <button type="submit" class="btn btn-primary">Submit</button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>

            <!--Edit Modal-->
            <div class="modal fade" id="editModal" tabindex="-1" aria-labelledby="editModalLabel" aria-hidden="true">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h1 class="modal-title fs-5" id="editModalLabel">Edit Inventory Record</h1>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <form action="inventory_core.jsp" method="POST">
                                <input type="hidden" name="action" value="submitEdit">
                                <input type="hidden" name="inv_id_edit" value="<%= inv_id_edit %>">
                                <div class="mb-3">
                                    <label for="item_name_edit" class="form-label">Quantity</label>
                                    <input type="text" class="form-control" id="item_name_edit" name="item_name_edit" value="<%= item_name_edit %>">
                                </div>
                                <div class="mb-3">
                                    <label for="type_of_inventory_edit" class="form-label">Type of Inventory</label>
                                    <select class="form-select" id="type_of_inventory_edit" name="type_of_inventory_edit">
                                        <option value="Tools"<%= "Tools".equals(type_of_inventory_edit) ? "selected" : "" %>>Tools</option>
                                        <option value="Materials" <%= "Materials".equals(type_of_inventory_edit) ? "selected" : "" %>>Materials</option>
                                        <option value="Funds" <%= "Funds".equals(type_of_inventory_edit) ? "selected" : "" %>>Funds</option>
                                        <option value="Other"<%= "Other".equals(type_of_inventory_edit) ? "selected" : "" %>>Other</option>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label for="unit_of_measurement_edit" class="form-label">Unit of Measurement</label>
                                    <select class="form-select" id="unit_of_measurement_edit" name="unit_of_measurement_edit">
                                        <option value="Piece" <%= "Piece".equals(unit_of_measurement_edit) ? "selected" : "" %>>Piece</option>
                                        <option value="Box" <%= "Box".equals(unit_of_measurement_edit) ? "selected" : "" %>>Box</option>
                                        <option value="Set"<%= "Set".equals(unit_of_measurement_edit) ? "selected" : "" %>>Set</option>
                                        <option value="Kilogram"<%= "Kilogram".equals(unit_of_measurement_edit) ? "selected" : "" %>>Kilogram</option>
                                        <option value="Meter"<%= "Meter".equals(unit_of_measurement_edit) ? "selected" : "" %>>Meter</option>
                                        <option value="Liter"<%= "Liter".equals(unit_of_measurement_edit) ? "selected" : "" %>>Liter</option>
                                        <option value="PHP"<%= "PHP".equals(unit_of_measurement_edit) ? "selected" : "" %>>PHP</option>
                                        <option value="Other"<%= "Other".equals(unit_of_measurement_edit) ? "selected" : "" %>>Other</option>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label for="category_edit" class="form-label">Category</label>
                                    <select class="form-select" id="category_edit" name="category_edit">
                                        <option value="General Repairs" <%= "General Repairs".equals(category_edit) ? "selected" : "" %>>General Repairs</option>
                                        <option value="Plumbing" <%= "Plumbing".equals(category_edit) ? "selected" : "" %>>Plumbing</option>
                                        <option value="Electrical"  <%= "Electrical".equals(category_edit) ? "selected" : "" %>>Electrical</option>
                                        <option value="Other" <%= "Other".equals(category_edit) ? "selected" : "" %>>Other</option>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label for="quantity_edit" class="form-label">Quantity</label>
                                    <input type="text" class="form-control" id="quantity_edit" name="quantity_edit" value="<%= quantity_edit %>">
                                </div>
                                <button type="submit" class="btn btn-primary">Save Changes</button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </body>
    </html>