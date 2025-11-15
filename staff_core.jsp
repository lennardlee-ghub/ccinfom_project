<%@page import="java.sql.*" %>

    <% 
        // Global variables for editing
        String staff_fname_edit = "";
        String staff_lname_edit = "";
        String staff_midname_edit = "";
        String staff_contact_number_edit = "";
        String availability_edit = "";
        int stf_id_edit = 0;

        // For inserting a record logic
        String action = request.getParameter("action");

        if("insert".equals(action)){
            // Modal insert variables
            String staff_fname_add = request.getParameter("staff_fname_add"); 
            String staff_lname_add = request.getParameter("staff_lname_add");
            String staff_midname_add = request.getParameter("staff_midname_add");
            String staff_contact_number_add = request.getParameter("staff_contact_number_add");
            String availability_add = request.getParameter("availability_add");

            // Connection
            Connection con;
            PreparedStatement pst;
            ResultSet rs; 

            // Insert statement
            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
            pst = con.prepareStatement("INSERT INTO staff_core(staff_fname, staff_lname, staff_midname, staff_contact_number, availability) VALUES(?,?,?,?,?)");
            pst.setString(1, staff_fname_add);
            pst.setString(2, staff_lname_add);
            pst.setString(3, staff_midname_add);
            pst.setString(4, staff_contact_number_add);
            pst.setString(5, availability_add);
            pst.executeUpdate();
            response.sendRedirect("staff_core.jsp");
        }
        else if("getEdit".equals(action)){
            // Getting the stf_id
            String stf_id_str = request.getParameter("stf_id");
            int stf_id = Integer.parseInt(stf_id_str);

            // Connection
            Connection con;
            PreparedStatement pst;
            ResultSet rs; 

            // Get the table data
            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
            pst = con.prepareStatement("SELECT * FROM staff_core WHERE stf_id=?");
            pst.setInt(1, stf_id);
            rs = pst.executeQuery();

            if(rs.next()){
                stf_id_edit = rs.getInt("stf_id");
                staff_fname_edit = rs.getString("staff_fname");
                staff_lname_edit = rs.getString("staff_lname");
                staff_midname_edit = rs.getString("staff_midname");
                staff_contact_number_edit = rs.getString("staff_contact_number");
                availability_edit = rs.getString("availability");
            }
            %>
            <script>
                window.onload = function() {
                    var editModal = new bootstrap.Modal(document.getElementById('editModal'));
                    editModal.show();
                };
            </script>
            <%
        } else if("submitEdit".equals(action)){
            // Get parameters from edit form
            int stf_id = Integer.parseInt(request.getParameter("stf_id_edit"));
            String staff_fname = request.getParameter("staff_fname_edit");
            String staff_lname = request.getParameter("staff_lname_edit");
            String staff_midname = request.getParameter("staff_midname_edit");
            String staff_contact_number = request.getParameter("staff_contact_number_edit");
            String availability = request.getParameter("availability_edit");

            // Connection
            Connection con;
            PreparedStatement pst;

            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
            pst = con.prepareStatement("UPDATE staff_core SET staff_fname=?, staff_lname=?, staff_midname=?, staff_contact_number=?, availability=? WHERE stf_id=?");
            pst.setString(1, staff_fname);
            pst.setString(2, staff_lname);
            pst.setString(3, staff_midname);
            pst.setString(4, staff_contact_number);
            pst.setString(5, availability);
            pst.setInt(6, stf_id);
            pst.executeUpdate();
            response.sendRedirect("staff_core.jsp");
        } else if("delete".equals(action)){
            // Get stf_id for deletion
            int stf_id = Integer.parseInt(request.getParameter("stf_id"));

            // Connection
            Connection con;
            PreparedStatement pst;

            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
            pst = con.prepareStatement("DELETE FROM staff_core WHERE stf_id=?");
            pst.setInt(1, stf_id);
            pst.executeUpdate();
            response.sendRedirect("staff_core.jsp");
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
                        <div style="width:100%;display:flex;justify-content:center;flex-direction:column;align-items:center">
                            <div class="d-flex" style="width:80%;margin-top:40px">
                                <div style="font-family:arial;font-size:28px;font-family:arial">
                                    Staff Records
                                </div>

                                <button class="btn btn-success fw-bold" type="button" style="margin-left:auto" data-bs-toggle="modal" data-bs-target="#addModal">
                                    Add Record
                                </button>
                            </div>

                            <div style="width:100%;display:flex;justify-content:center;margin-top:20px">
                                <table class="table table-striped" style="width:80%">
                                    <thead>
                                        <tr>
                                            <td class="fw-bold">First Name</td>
                                            <td class="fw-bold">Last Name</td>
                                            <td class="fw-bold">Middle Initial</td>
                                            <td class="fw-bold">Contact Number</td>
                                            <td class="fw-bold">Availability</td>
                                            <td class="fw-bold text-center">Action</td>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <%
                                            Connection con;
                                            PreparedStatement pst;
                                            ResultSet rs; 
                                    
                                            Class.forName("com.mysql.jdbc.Driver");
                                            con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");

                                            String query = "SELECT * FROM staff_core";
                                            Statement st = con.createStatement();
                                            rs = st.executeQuery(query);

                                            while(rs.next())
                                            {
                                                int stf_id = rs.getInt("stf_id");
                                        %>
                                        <tr>
                                            <td><%= rs.getString("staff_fname") %></td>
                                            <td><%= rs.getString("staff_lname") %></td>
                                            <td><%= rs.getString("staff_midname") %></td>
                                            <td><%= rs.getString("staff_contact_number") %></td>
                                            <td><%= rs.getString("availability") %></td>
                                            <td>
                                                <div class="dropdown text-center">
                                                    <button class="btn btn-primary fw-bold" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                                                    Action
                                                    </button>
                                                    <ul class="dropdown-menu">
                                                        <li><a class="dropdown-item" href="staff_core.jsp?action=getEdit&stf_id=<%= stf_id %>">Edit</a></li>
                                                        <li><a class="dropdown-item" href="staff_core.jsp?action=delete&stf_id=<%= stf_id %>" onclick="return confirm('Are you sure you want to delete this record?');">Delete</a></li>
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
                        </div>
                    </td>
                </tr>
            </table>

            <!-- Add Modal -->
            <div class="modal fade" id="addModal" tabindex="-1" aria-labelledby="addModalLabel" aria-hidden="true">
              <div class="modal-dialog">
                <div class="modal-content">
                  <div class="modal-header">
                    <h1 class="modal-title fs-5" id="addModalLabel">Add Staff Record</h1>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                  </div>
                  <div class="modal-body">
                    <form action="staff_core.jsp" method="POST">
                        <input type="hidden" name="action" value="insert">
                        <div class="mb-3">
                            <label for="staff_fname_add" class="form-label">First Name</label>
                            <input type="text" class="form-control" id="staff_fname_add" name="staff_fname_add">
                        </div>
                        <div class="mb-3">
                            <label for="staff_lname_add" class="form-label">Last Name</label>
                            <input type="text" class="form-control" id="staff_lname_add" name="staff_lname_add">
                        </div>
                        <div class="mb-3">
                            <label for="staff_midname_add" class="form-label">Middle Initial</label>
                            <input type="text" class="form-control" id="staff_midname_add" name="staff_midname_add">
                        </div>
                        <div class="mb-3">
                            <label for="staff_contact_number_add" class="form-label">Contact Number</label>
                            <input type="text" class="form-control" id="staff_contact_number_add" name="staff_contact_number_add">
                        </div>
                        <div class="mb-3">
                            <label for="availability_add" class="form-label">Availability</label>
                            <select class="form-select" id="availability_add" name="availability_add">
                                <option value="Available">Available</option>
                                <option value="Not Available">Not Available</option>
                            </select>
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
                    <h1 class="modal-title fs-5" id="editModalLabel">Edit Staff Record</h1>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                  </div>
                  <div class="modal-body">
                    <form action="staff_core.jsp" method="POST">
                        <input type="hidden" name="action" value="submitEdit">
                        <input type="hidden" name="stf_id_edit" value="<%= stf_id_edit %>">
                        <div class="mb-3">
                            <label for="staff_fname_edit" class="form-label">First Name</label>
                            <input type="text" class="form-control" id="staff_fname_edit" name="staff_fname_edit" value="<%= staff_fname_edit %>">
                        </div>
                        <div class="mb-3">
                            <label for="staff_lname_edit" class="form-label">Last Name</label>
                            <input type="text" class="form-control" id="staff_lname_edit" name="staff_lname_edit" value="<%= staff_lname_edit %>">
                        </div>
                        <div class="mb-3">
                            <label for="staff_midname_edit" class="form-label">Middle Initial</label>
                            <input type="text" class="form-control" id="staff_midname_edit" name="staff_midname_edit" value="<%= staff_midname_edit %>">
                        </div>
                        <div class="mb-3">
                            <label for="staff_contact_number_edit" class="form-label">Contact Number</label>
                            <input type="text" class="form-control" id="staff_contact_number_edit" name="staff_contact_number_edit" value="<%= staff_contact_number_edit %>">
                        </div>
                        <div class="mb-3">
                            <label for="availability_edit" class="form-label">Availability</label>
                            <select class="form-select" id="availability_edit" name="availability_edit">
                                <option value="Available" <%="Available".equals(availability_edit) ? "selected" : ""%>>Available</option>
                                <option value="Not Available" <%="Not Available".equals(availability_edit) ? "selected" : ""%>>Not Available</option>
                            </select>
                        </div>
                        <button type="submit" class="btn btn-primary">Save Changes</button>
                    </form>
                  </div>
                </div>
              </div>
            </div>
        </body>
    </html>