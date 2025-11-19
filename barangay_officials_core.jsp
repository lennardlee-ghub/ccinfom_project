<%@page import="java.sql.*" %>

<% 
    //global variables for editing
    String official_fname_edit = "";
    String official_lname_edit = "";
    String official_midname_edit = "";
    String office_edit = "";
    String address_edit = "";
    String availability_edit = "";
    int boff_id_edit = 0;

    //for inserting a record logic
    String action = request.getParameter("action");

    if("insert".equals(action)){

        //modal insert variables
        String official_fname_add = request.getParameter("official_fname_add"); 
        String official_lname_add = request.getParameter("official_lname_add");
        String official_midname_add = request.getParameter("official_midname_add");
        String office_add = request.getParameter("office_add");
        String address_add = request.getParameter("address_add");
        String availability_add = request.getParameter("availability_add");

        //connection
        Connection con = null;
        PreparedStatement pst = null;

        try {
            //insert statement
            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
            pst = con.prepareStatement("INSERT INTO barangay_officials_core(official_fname, official_lname, official_midname, office, address, availability) VALUES(?,?,?,?,?,?)");
            pst.setString(1, official_fname_add);
            pst.setString(2, official_lname_add);
            pst.setString(3, official_midname_add);
            pst.setString(4, office_add);
            pst.setString(5, address_add);
            pst.setString(6, availability_add);
            pst.executeUpdate();
        } catch(Exception e) {
            out.println("Error: " + e.getMessage());
            e.printStackTrace();
        } finally {
            if(pst != null) try { pst.close(); } catch(Exception e) {}
            if(con != null) try { con.close(); } catch(Exception e) {}
        }

    }
    else if("getEdit".equals(action)){

        //getting the boff_id which is the primary key
        String boff_id_str = request.getParameter("boff_id");

        //converting to int
        int boff_id = Integer.parseInt(boff_id_str);

        //connection
        Connection con;
        PreparedStatement pst;
        ResultSet rs; 

        //get the record to edit
        Class.forName("com.mysql.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
        pst = con.prepareStatement("SELECT * FROM barangay_officials_core WHERE boff_id=?");
        pst.setInt(1, boff_id);
        rs = pst.executeQuery();

        if(rs.next()){
            official_fname_edit = rs.getString("official_fname");
            official_lname_edit = rs.getString("official_lname");
            official_midname_edit = rs.getString("official_midname");
            office_edit = rs.getString("office");
            address_edit = rs.getString("address");
            availability_edit = rs.getString("availability");
            boff_id_edit = rs.getInt("boff_id");
        }

        %>

        <script>
            //show the modal
            document.addEventListener('DOMContentLoaded', function() {
                var editModal = new bootstrap.Modal(document.getElementById('editModal'));
                editModal.show();
            });
        </script>

        <%

    }else if("submitEdit".equals(action)){
        
        //modal edit variables
        official_fname_edit = request.getParameter("official_fname_edit"); 
        official_lname_edit = request.getParameter("official_lname_edit");
        official_midname_edit = request.getParameter("official_midname_edit");
        office_edit = request.getParameter("office_edit");
        address_edit = request.getParameter("address_edit");
        availability_edit = request.getParameter("availability_edit");
        String boff_id_hidden_str = request.getParameter("boff_id_hidden");
        //parsing to int
        int boff_id_hidden = Integer.parseInt(boff_id_hidden_str);

        //connection
        Connection con;
        PreparedStatement pst;
        ResultSet rs; 

        //submit edit statement
        Class.forName("com.mysql.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
        pst = con.prepareStatement("UPDATE barangay_officials_core SET official_fname=?, official_lname=?, official_midname=?, office=?, address=?, availability=? WHERE boff_id=?");
        pst.setString(1, official_fname_edit);
        pst.setString(2, official_lname_edit);
        pst.setString(3, official_midname_edit);
        pst.setString(4, office_edit);
        pst.setString(5, address_edit);
        pst.setString(6, availability_edit);
        pst.setInt(7, boff_id_hidden);
        pst.executeUpdate();

        %>

        <script>
            //hide the modal
            document.addEventListener('DOMContentLoaded', function() {
                var editModal = new bootstrap.Modal(document.getElementById('editModal'));
                editModal.hide();
            });
        </script>

        <%
    }  
    
    else if("delete".equals(action)){

        //connection
        Connection con;
        PreparedStatement pst;
        ResultSet rs;

        String boff_id_delete_str = request.getParameter("boff_id");
        //parsing to int
        int boff_id_delete = Integer.parseInt(boff_id_delete_str);

        Class.forName("com.mysql.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
        pst = con.prepareStatement("DELETE FROM barangay_officials_core WHERE boff_id=?");
        pst.setInt(1, boff_id_delete);
        pst.executeUpdate();
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
        <!-- for the css file-->
        <link rel="stylesheet" href="bootstrap-5.2.3-dist/css/bootstrap.css">
    </head>

    <body style="overflow:hidden">
        <table style="overflow:none">

            <tr>
                <td>
                    <jsp:include page="/sidebar.jsp" />
                </td>

                <td style="width:calc(100vw - 350px)" class="d-flex align-items-center">

                    <form method="POST" action="" style="width:100%;height:100%">

                        <div style="width:100%;display:flex;justify-content:center;flex-direction:column;align-items:center">
                            <div class="d-flex" style="width:80%;margin-top:40px">
                                <div style="font-family:arial;font-size:28px;font-family:arial">
                                    Barangay Officials Record
                                </div>

                                <button class="btn btn-success fw-bold" type="button" style="margin-left:auto" data-bs-toggle="modal" data-bs-target="#addModal">
                                    Add Record
                                </button>
                            </div>

                            <div style="width:100%;display:flex;justify-content:center;margin-top:20px">
                                <table class="table table-striped" style="width:80%">
                                    <thead>
                                        <tr>
                                           

                                            <td class="fw-bold">
                                                First Name
                                            </td>

                                            <td class="fw-bold">
                                                Last Name
                                            </td>

                                            <td class="fw-bold">
                                                Middle Initial
                                            </td>

                                            <td class="fw-bold">
                                                Department
                                            </td>

                                            <td class="fw-bold">
                                                Address
                                            </td>

                                            <td class="fw-bold">
                                                Availability
                                            </td>

                                            <td class="fw-bold text-center">
                                                Action
                                            </td>
                                        </tr>
                                    </thead>

                                    <%
                                        Connection con;
                                        PreparedStatement pat;
                                        ResultSet rs; 
                                
                                        Class.forName("com.mysql.jdbc.Driver");
                                        con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");

                                        String query = "select * FROM barangay_officials_core";
                                        Statement st = con.createStatement();
                                        rs = st.executeQuery(query);

                                        while(rs.next())
                                        {
                                            int boff_id = rs.getInt("boff_id");
                                            String official_fname = rs.getString("official_fname");
                                            String official_lname = rs.getString("official_lname");
                                            String official_midname = rs.getString("official_midname");
                                            String office = rs.getString("office");
                                            String address = rs.getString("address");
                                            String availability = rs.getString("availability");

                                    %>
                                    <tr>
                                        <td><%=official_fname%></td>
                                        <td><%=official_lname%></td>
                                        <td><%=official_midname%></td>
                                        <td><%=office%></td>
                                        <td><%=address%></td>
                                        <td><%=availability%></td>
                                        <td>
                                            <div class="dropdown text-center">
                                                <button class="btn btn-primary fw-bold" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                                                Action
                                                </button>
                                                <ul class="dropdown-menu">
                                                <li><a class="dropdown-item" href="?action=getEdit&boff_id=<%=boff_id%>">Edit</a></li>
                                                <li><a class="dropdown-item" href="?action=delete&boff_id=<%=boff_id%>">Delete</a></li>
                                                </ul>
                                          </div>
                                        </td>
                                    </tr>

                                    <%
                                        }
                                    %>

                                </table>
                            </div>
                        </div>
                    </form>

                    <!-- ADD MODAL -->
                    <div class="modal fade" id="addModal" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <form>
                                    <div class="modal-header">
                                    <h5 class="modal-title" id="exampleModalLabel">Add Barangay Official</h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                    </div>
                                    <div class="modal-body">
                                    
                                        <div class="mb-3">
                                        <label for="official_fname_add" class="col-form-label">First Name:</label>
                                        <input type="text" name="official_fname_add" id="official_fname_add" class="form-control">
                                        </div>
                                        <div class="mb-3">
                                        <label for="official_lname_add" class="col-form-label">Last Name:</label>
                                        <input type="text" name="official_lname_add" id="official_lname_add" class="form-control">
                                        </div>
                                        <div class="mb-3">
                                        <label for="official_midname_add" class="col-form-label">Middle Name:</label>
                                        <input type="text" name="official_midname_add" id="official_midname_add" class="form-control">
                                        </div>
                                        <div class="mb-3">
                                            <label for="office_add" class="col-form-label">Department:</label>
                                            <select name="office_add" class="form-select" id="office_add">
                                                <option>Captain/Admin</option>
                                                <option>Councilors</option>
                                                <option>Chairperson</option>
                                                <option>Secretary</option>
                                                <option>Treasurer</option>
                                            </select>
                                        </div>
                                        <div class="mb-3">
                                            <label for="address_add" class="col-form-label">Address:</label>
                                            <input type="text" name="address_add" id="address_add" class="form-control">
                                        </div>
                                        <div class="mb-3">
                                            <label for="availability_add" class="col-form-label">Availability:</label>
                                            <select name="availability_add" class="form-select" id="availability_add">
                                                <option>Available</option>
                                                <option>Not Available</option>
                                            </select>
                                        </div>                        
                                
                                    </div>
                                    <div class="modal-footer">
                                    <button type="button" class="btn btn-danger" data-bs-dismiss="modal">Close</button>
                                    <button class="btn btn-primary" type="submit" name="action" value="insert">Add</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>

                    <!-- EDIT MODAL-->
                    <div class="modal fade" id="editModal" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <form>
                                    <div class="modal-header">
                                        <h5 class="modal-title" id="exampleModalLabel">Edit Barangay Official</h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                    </div>
                                    <div class="modal-body">
                                
                                        <div class="mb-3">
                                        <label for="official_fname_edit" class="col-form-label">First Name:</label>
                                        <input type="text" name="official_fname_edit" id="official_fname_edit" class="form-control" value="<%=official_fname_edit%>">
                                        </div>
                                        <div class="mb-3">
                                        <label for="official_lname_edit" class="col-form-label">Last Name:</label>
                                        <input type="text" name="official_lname_edit" id="official_lname_edit" class="form-control" value="<%=official_lname_edit%>">
                                        </div>
                                        <div class="mb-3">
                                        <label for="official_midname_edit" class="col-form-label">Middle Name:</label>
                                        <input type="text" name="official_midname_edit" id="official_midname_edit" class="form-control" value="<%=official_midname_edit%>">
                                        </div>
                                        <div class="mb-3">
                                            <label for="office_edit" class="col-form-label">Office:</label>
                                            <select name="office_edit" class="form-select" id="office_edit">
                                                <option <%="Barangay Captain".equals(office_edit) ? "selected" : ""%>>Barangay Captain</option>
                                                <option <%="Barangay Kagawad".equals(office_edit) ? "selected" : ""%>>Barangay Kagawad</option>
                                                <option <%="SK Chairperson".equals(office_edit) ? "selected" : ""%>>SK Chairperson</option>
                                                <option <%="Barangay Secretary".equals(office_edit) ? "selected" : ""%>>Barangay Secretary</option>
                                                <option <%="Barangay Treasurer".equals(office_edit) ? "selected" : ""%>>Barangay Treasurer</option>
                                            </select>
                                        </div>
                                        <div class="mb-3">
                                            <label for="address_edit" class="col-form-label">Address:</label>
                                            <input type="text" name="address_edit" id="address_edit" class="form-control" value="<%=address_edit%>">
                                        </div>
                                        <div class="mb-3">
                                            <label for="availability_edit" class="col-form-label">Availability:</label>
                                            <select name="availability_edit" class="form-select" id="availability_edit">
                                                <option <%="Available".equals(availability_edit) ? "selected" : ""%>>Available</option>
                                                <option <%="Not Available".equals(availability_edit) ? "selected" : ""%>>Not Available</option>
                                            </select>
                                        </div>                        
                                
                                    </div>

                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-danger" data-bs-dismiss="modal">Close</button>
                                        <button class="btn btn-primary" type="submit" name="action" id="action" value="submitEdit">Update</button>

                                        <input type="hidden" name="boff_id_hidden" id="boff_id_hidden" value="<%=boff_id_edit%>">
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </td>
            </tr>
        </table>

    </body>
</html>