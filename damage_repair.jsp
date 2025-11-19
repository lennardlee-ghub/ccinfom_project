    
    <%@page import="java.sql.*" %>

    <% 
        // Global variables for editing
        int dr_id_edit = 0;
        String date_start_edit = "";
        String date_end_edit = "";
        String status_edit = "";
        int dri_id_edit = 0;

        // For inserting a record logic
        String action = request.getParameter("action");

        if("insert".equals(action)){
            // Modal insert variables
            String date_start_add = request.getParameter("date_start_add"); 
            String date_end_add = request.getParameter("date_end_add");
            String status_add = request.getParameter("status_add");
            String dri_id_add_str = request.getParameter("dri_id_add");
            
            int dri_id_add = Integer.parseInt(dri_id_add_str);

            // Connection
            Connection con;
            PreparedStatement pst;

            // Insert statement
            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
            pst = con.prepareStatement("INSERT INTO damage_repair(date_start, date_end, status, dri_id) VALUES(?,?,?,?)");
            pst.setString(1, date_start_add);
            pst.setString(2, date_end_add);
            pst.setString(3, status_add);
            pst.setInt(4, dri_id_add);
            pst.executeUpdate();
            
            // Update staff availability based on status
            if("For Repair".equals(status_add) || "Repairing".equals(status_add)){
                pst = con.prepareStatement("UPDATE staff_core SET availability='Not Available' WHERE stf_id = (SELECT stf_id FROM damage_recording_infra WHERE dri_id=?)");
                pst.setInt(1, dri_id_add);
                pst.executeUpdate();
            } else if("Repaired".equals(status_add)){
                pst = con.prepareStatement("UPDATE staff_core SET availability='Available' WHERE stf_id = (SELECT stf_id FROM damage_recording_infra WHERE dri_id=?)");
                pst.setInt(1, dri_id_add);
                pst.executeUpdate();
                
                // Update infrastructure status to 'No need repair'
                pst = con.prepareStatement("UPDATE infrastructure_core SET status='No need repair' WHERE inf_id = (SELECT inf_id FROM damage_recording_infra WHERE dri_id=?)");
                pst.setInt(1, dri_id_add);
                pst.executeUpdate();
            }
            
            con.close();
            response.sendRedirect("damage_repair.jsp");
        }
        else if("getEdit".equals(action)){
            // Getting the dr_id
            String dr_id_str = request.getParameter("dr_id");
            int dr_id = Integer.parseInt(dr_id_str);

            // Connection
            Connection con;
            PreparedStatement pst;
            ResultSet rs; 

            // Get the table data
            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
            pst = con.prepareStatement("SELECT * FROM damage_repair WHERE dr_id=?");
            pst.setInt(1, dr_id);
            rs = pst.executeQuery();

            if(rs.next()){
                dr_id_edit = rs.getInt("dr_id");
                date_start_edit = rs.getString("date_start");
                date_end_edit = rs.getString("date_end");
                status_edit = rs.getString("status");
                dri_id_edit = rs.getInt("dri_id");
            }
            con.close();
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
            int dr_id = Integer.parseInt(request.getParameter("dr_id_edit"));
            String date_start = request.getParameter("date_start_edit");
            String date_end = request.getParameter("date_end_edit");
            String status = request.getParameter("status_edit");
            int dri_id = Integer.parseInt(request.getParameter("dri_id_edit"));

            // Connection
            Connection con;
            PreparedStatement pst;
            ResultSet rs;

            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
            
            // Get the old status before updating
            pst = con.prepareStatement("SELECT status FROM damage_repair WHERE dr_id=?");
            pst.setInt(1, dr_id);
            rs = pst.executeQuery();
            String old_status = "";
            if(rs.next()){
                old_status = rs.getString("status");
            }
            
            // Update the damage_repair record
            pst = con.prepareStatement("UPDATE damage_repair SET date_start=?, date_end=?, status=?, dri_id=? WHERE dr_id=?");
            pst.setString(1, date_start);
            pst.setString(2, date_end);
            pst.setString(3, status);
            pst.setInt(4, dri_id);
            pst.setInt(5, dr_id);
            pst.executeUpdate();
            
            // If changing FROM Repaired to something else, restore infrastructure to Damaged
            if("Repaired".equals(old_status) && !"Repaired".equals(status)){
                pst = con.prepareStatement("UPDATE infrastructure_core SET status='Damaged' WHERE inf_id = (SELECT inf_id FROM damage_recording_infra WHERE dri_id=?)");
                pst.setInt(1, dri_id);
                pst.executeUpdate();
            }
            
            // Update staff availability based on new status
            if("For Repair".equals(status) || "Repairing".equals(status)){
                pst = con.prepareStatement("UPDATE staff_core SET availability='Not Available' WHERE stf_id = (SELECT stf_id FROM damage_recording_infra WHERE dri_id=?)");
                pst.setInt(1, dri_id);
                pst.executeUpdate();
            } else if("Repaired".equals(status)){
                pst = con.prepareStatement("UPDATE staff_core SET availability='Available' WHERE stf_id = (SELECT stf_id FROM damage_recording_infra WHERE dri_id=?)");
                pst.setInt(1, dri_id);
                pst.executeUpdate();
                
                // Update infrastructure status to 'No need repair'
                pst = con.prepareStatement("UPDATE infrastructure_core SET status='No need repair' WHERE inf_id = (SELECT inf_id FROM damage_recording_infra WHERE dri_id=?)");
                pst.setInt(1, dri_id);
                pst.executeUpdate();
            }
            
            con.close();
            response.sendRedirect("damage_repair.jsp");
        } else if("delete".equals(action)){
            // Get dr_id for deletion
            int dr_id = Integer.parseInt(request.getParameter("dr_id"));

            // Connection
            Connection con;
            PreparedStatement pst;
            ResultSet rs;

            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
            
            // Get the status and dri_id before deleting
            pst = con.prepareStatement("SELECT status, dri_id FROM damage_repair WHERE dr_id=?");
            pst.setInt(1, dr_id);
            rs = pst.executeQuery();
            String status_to_delete = "";
            int dri_id_to_restore = 0;
            if(rs.next()){
                status_to_delete = rs.getString("status");
                dri_id_to_restore = rs.getInt("dri_id");
            }
            
            // If deleting a Repaired record, restore infrastructure to Damaged
            if("Repaired".equals(status_to_delete)){
                pst = con.prepareStatement("UPDATE infrastructure_core SET status='Damaged' WHERE inf_id = (SELECT inf_id FROM damage_recording_infra WHERE dri_id=?)");
                pst.setInt(1, dri_id_to_restore);
                pst.executeUpdate();
            }
            
            // Delete the damage_repair record
            pst = con.prepareStatement("DELETE FROM damage_repair WHERE dr_id=?");
            pst.setInt(1, dr_id);
            pst.executeUpdate();
            con.close();
            response.sendRedirect("damage_repair.jsp");
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
                                    Damage Repair Records
                                </div>

                                <button class="btn btn-success fw-bold" type="button" style="margin-left:auto" data-bs-toggle="modal" data-bs-target="#addModal">
                                    Add Record
                                </button>
                            </div>

                            <div style="width:100%;display:flex;justify-content:center;margin-top:20px">
                                <table class="table table-striped" style="width:80%">
                                    <thead>
                                        <tr>
                                            <td class="fw-bold">ID</td>
                                            <td class="fw-bold">Infrastructure</td>
                                            <td class="fw-bold">Status</td>
                                            <td class="fw-bold">Assigned Staff</td>
                                            <td class="fw-bold">Date Start</td>
                                            <td class="fw-bold">Date End</td>
                                            <td class="fw-bold text-center">Action</td>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <%
                                            try {
                                                Connection con;
                                                ResultSet rs; 
                                        
                                                Class.forName("com.mysql.jdbc.Driver");
                                                con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");

                                                String query = "SELECT dr.dr_id, dr.date_start, dr.date_end, dr.status, " +
                                                              "i.location AS infrastructure, " +
                                                              "CONCAT(s.staff_fname, ' ', s.staff_lname) AS staff_name " +
                                                              "FROM damage_repair dr " +
                                                              "LEFT JOIN damage_recording_infra dri ON dr.dri_id = dri.dri_id " +
                                                              "LEFT JOIN infrastructure_core i ON dri.inf_id = i.inf_id " +
                                                              "LEFT JOIN staff_core s ON dri.stf_id = s.stf_id " +
                                                              "ORDER BY dr.dr_id DESC";
                                                Statement st = con.createStatement();
                                                rs = st.executeQuery(query);

                                                while(rs.next())
                                                {
                                                    int dr_id = rs.getInt("dr_id");
                                        %>
                                        <tr>
                                            <td><%= dr_id %></td>
                                            <td><%= rs.getString("infrastructure") %></td>
                                            <td><%= rs.getString("status") %></td>
                                            <td><%= rs.getString("staff_name") %></td>
                                            <td><%= rs.getString("date_start") %></td>
                                            <td><%= rs.getString("date_end") %></td>
                                            <td>
                                                <div class="dropdown text-center">
                                                    <button class="btn btn-primary fw-bold" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                                                    Action
                                                    </button>
                                                    <ul class="dropdown-menu">
                                                        <li><a class="dropdown-item" href="damage_repair.jsp?action=getEdit&dr_id=<%= dr_id %>">Edit</a></li>
                                                        <li><a class="dropdown-item" href="damage_repair.jsp?action=delete&dr_id=<%= dr_id %>" onclick="return confirm('Are you sure you want to delete this record?');">Delete</a></li>
                                                    </ul>
                                              </div>
                                            </td>
                                        </tr>
                                        <%
                                                }
                                                con.close();
                                            } catch(Exception e) {
                                        %>
                                        <tr>
                                            <td colspan="7" class="text-center text-danger">
                                                <strong>Error loading records:</strong> <%= e.getMessage() %>
                                            </td>
                                        </tr>
                                        <%
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
                    <h1 class="modal-title fs-5" id="addModalLabel">Add Damage Repair Record</h1>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                  </div>
                  <div class="modal-body">
                    <form action="damage_repair.jsp" method="POST">
                        <input type="hidden" name="action" value="insert">
                        <div class="mb-3">
                            <label for="dri_id_add" class="form-label">Damage Record</label>
                            <select class="form-select" id="dri_id_add" name="dri_id_add" required>
                                <option value="">Select Damage Record</option>
                                <%
                                    Connection con2;
                                    Statement st2;
                                    ResultSet rs2;
                                    
                                    Class.forName("com.mysql.jdbc.Driver");
                                    con2 = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
                                    st2 = con2.createStatement();
                                    rs2 = st2.executeQuery("SELECT dri.dri_id, i.location, dri.damage_details " +
                                                          "FROM damage_recording_infra dri " +
                                                          "LEFT JOIN infrastructure_core i ON dri.inf_id = i.inf_id " +
                                                          "ORDER BY dri.dri_id DESC");
                                    
                                    while(rs2.next()){
                                %>
                                    <option value="<%= rs2.getInt("dri_id") %>">
                                        #<%= rs2.getInt("dri_id") %> - <%= rs2.getString("location") %> - <%= rs2.getString("damage_details") %>
                                    </option>
                                <%
                                    }
                                    con2.close();
                                %>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label for="status_add" class="form-label">Status</label>
                            <select class="form-select" id="status_add" name="status_add" required>
                                <option value="For Repair">For Repair</option>
                                <option value="Repairing">Repairing</option>
                                <option value="Repaired">Repaired</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label for="date_start_add" class="form-label">Date Start</label>
                            <input type="date" class="form-control" id="date_start_add" name="date_start_add" required>
                        </div>
                        <div class="mb-3">
                            <label for="date_end_add" class="form-label">Date End</label>
                            <input type="date" class="form-control" id="date_end_add" name="date_end_add">
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
                    <h1 class="modal-title fs-5" id="editModalLabel">Edit Damage Repair Record</h1>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                  </div>
                  <div class="modal-body">
                    <form action="damage_repair.jsp" method="POST">
                        <input type="hidden" name="action" value="submitEdit">
                        <input type="hidden" name="dr_id_edit" value="<%= dr_id_edit %>">
                        <div class="mb-3">
                            <label for="dri_id_edit" class="form-label">Damage Record</label>
                            <select class="form-select" id="dri_id_edit" name="dri_id_edit" required>
                                <%
                                    Connection con4;
                                    Statement st4;
                                    ResultSet rs4;
                                    
                                    Class.forName("com.mysql.jdbc.Driver");
                                    con4 = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
                                    st4 = con4.createStatement();
                                    rs4 = st4.executeQuery("SELECT dri.dri_id, i.location, dri.damage_details " +
                                                          "FROM damage_recording_infra dri " +
                                                          "LEFT JOIN infrastructure_core i ON dri.inf_id = i.inf_id " +
                                                          "ORDER BY dri.dri_id DESC");
                                    
                                    while(rs4.next()){
                                        int dri_id_option = rs4.getInt("dri_id");
                                        String selected = (dri_id_option == dri_id_edit) ? "selected" : "";
                                %>
                                    <option value="<%= dri_id_option %>" <%= selected %>>
                                        #<%= dri_id_option %> - <%= rs4.getString("location") %> - <%= rs4.getString("damage_details") %>
                                    </option>
                                <%
                                    }
                                    con4.close();
                                %>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label for="status_edit" class="form-label">Status</label>
                            <select class="form-select" id="status_edit" name="status_edit" required>
                                <option value="For Repair" <%= "For Repair".equals(status_edit) ? "selected" : "" %>>For Repair</option>
                                <option value="Repairing" <%= "Repairing".equals(status_edit) ? "selected" : "" %>>Repairing</option>
                                <option value="Repaired" <%= "Repaired".equals(status_edit) ? "selected" : "" %>>Repaired</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label for="date_start_edit" class="form-label">Date Start</label>
                            <input type="date" class="form-control" id="date_start_edit" name="date_start_edit" value="<%= date_start_edit %>" required>
                        </div>
                        <div class="mb-3">
                            <label for="date_end_edit" class="form-label">Date End</label>
                            <input type="date" class="form-control" id="date_end_edit" name="date_end_edit" value="<%= date_end_edit %>">
                        </div>
                        <button type="submit" class="btn btn-primary">Save Changes</button>
                    </form>
                  </div>
                </div>
              </div>
            </div>
        </body>
    </html>