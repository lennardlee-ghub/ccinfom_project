    
    <%@page import="java.sql.*" %>
    <%
        //global variables for editing
        int dri_id_edit = 0;
        String damage_details_edit = "";
        String cause_of_damage_edit = "";
        String date_recorded_edit = "";
        String date_staff_assigned_edit = "";
        int inf_id_edit = 0;
        int stf_id_edit = 0;

        //For inserting a record logic
        String action = request.getParameter("action");

        if("insert".equals(action))
        {
            //Modal insert variables
            String damage_details_add = request.getParameter("damage_details_add");
            String cause_of_damage_add = request.getParameter("cause_of_damage_add");
            String date_recorded_add = request.getParameter("date_recorded_add");
            String date_staff_assigned_add = request.getParameter("date_staff_assigned_add");
            String inf_id_str = request.getParameter("inf_id_add");
            int inf_id_add = Integer.parseInt(inf_id_str);
            String stf_id_str = request.getParameter("stf_id_add");
            Integer stf_id_add = null;
            if(stf_id_str != null && !stf_id_str.isEmpty()) {
                stf_id_add = Integer.parseInt(stf_id_str);
            }

            //Connection
            Connection con;
            PreparedStatement pst;

            // Insert statement
            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
            pst = con.prepareStatement("INSERT INTO damage_recording_infra(damage_details, cause_of_damage, date_recorded, date_staff_assigned, stf_id, inf_id) VALUES(?,?,?,?,?,?)");
            pst.setString(1, damage_details_add);
            pst.setString(2, cause_of_damage_add);
            pst.setString(3, date_recorded_add);
            
            // Handle optional date and staff
            if(date_staff_assigned_add == null || date_staff_assigned_add.isEmpty()) {
                pst.setNull(4, java.sql.Types.DATE);
            } else {
                pst.setString(4, date_staff_assigned_add);
            }
            
            if(stf_id_add == null) {
                pst.setNull(5, java.sql.Types.INTEGER);
            } else {
                pst.setInt(5, stf_id_add);
            }
            
            pst.setInt(6, inf_id_add);
            pst.executeUpdate();

            //Update Infrastructure status
            pst = con.prepareStatement("UPDATE infrastructure_core SET status='Damaged' WHERE inf_id=?");
            pst.setInt(1, inf_id_add);
            pst.executeUpdate();

            //Update Staff availability only if staff was assigned
            if(stf_id_add != null) {
                pst = con.prepareStatement("UPDATE staff_core SET availability='Not Available' WHERE stf_id=?");
                pst.setInt(1, stf_id_add);
                pst.executeUpdate();
            }

            con.close();
            response.sendRedirect("damage_recording.jsp");
        }
        else if("getEdit".equals(action))
        {
            //Getting the dri_id
            String dri_id_str = request.getParameter("dri_id");
            int dri_id = Integer.parseInt(dri_id_str);

            //Connection
            Connection con;
            PreparedStatement pst;
            ResultSet rs;

            //get the table data
            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
            pst = con.prepareStatement("SELECT * FROM damage_recording_infra WHERE dri_id=?");
            pst.setInt(1, dri_id);
            rs = pst.executeQuery();

            if(rs.next())
            {
                dri_id_edit = rs.getInt("dri_id");
                damage_details_edit = rs.getString("damage_details");
                cause_of_damage_edit = rs.getString("cause_of_damage");
                date_recorded_edit = rs.getString("date_recorded");
                date_staff_assigned_edit = rs.getString("date_staff_assigned");
                stf_id_edit = rs.getInt("stf_id");
                inf_id_edit = rs.getInt("inf_id");
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
        }
        else if("submitEdit".equals(action))
        {
            // get parameters from edit form
            int dri_id = Integer.parseInt(request.getParameter("dri_id_edit"));
            String damage_details = request.getParameter("damage_details_edit");
            String cause_of_damage = request.getParameter("cause_of_damage_edit");
            String date_recorded = request.getParameter("date_recorded_edit");
            String date_staff_assigned = request.getParameter("date_staff_assigned_edit");
            int inf_id = Integer.parseInt(request.getParameter("inf_id_edit"));
            String stf_id_str = request.getParameter("stf_id_edit");
            Integer stf_id = null;
            if(stf_id_str != null && !stf_id_str.isEmpty()) {
                stf_id = Integer.parseInt(stf_id_str);
            }

            //Connection
            Connection con;
            PreparedStatement pst;
            
            //Update statement
            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
            pst = con.prepareStatement("UPDATE damage_recording_infra SET damage_details=?, cause_of_damage=?, date_recorded=?, date_staff_assigned=?, stf_id=?, inf_id=? WHERE dri_id=?");
            pst.setString(1, damage_details);
            pst.setString(2, cause_of_damage);
            pst.setString(3, date_recorded);
            
            // Handle optional date and staff
            if(date_staff_assigned == null || date_staff_assigned.isEmpty()) {
                pst.setNull(4, java.sql.Types.DATE);
            } else {
                pst.setString(4, date_staff_assigned);
            }
            
            if(stf_id == null) {
                pst.setNull(5, java.sql.Types.INTEGER);
            } else {
                pst.setInt(5, stf_id);
            }
            
            pst.setInt(6, inf_id);
            pst.setInt(7, dri_id);
            pst.executeUpdate();

            //Update Infrastructure status
            pst = con.prepareStatement("UPDATE infrastructure_core SET status='Damaged' WHERE inf_id=(SELECT inf_id FROM damage_recording_infra WHERE dri_id=?)");
            pst.setInt(1, inf_id);
            pst.executeUpdate();

            //Update Staff availability only if staff was assigned
            if(stf_id != null) {
                pst = con.prepareStatement("UPDATE staff_core SET availability='Not Available' WHERE stf_id=(SELECT stf_id FROM damage_recording_infra WHERE dri_id=?)");
                pst.setInt(1, stf_id);
                pst.executeUpdate();
            }

            con.close();
            response.sendRedirect("damage_recording.jsp");
        }
        else if("delete".equals(action))
        {
            // Get dri_id for deletion
            int dri_id = Integer.parseInt(request.getParameter("dri_id"));

            // Connection
            Connection con;
            PreparedStatement pst;

            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
            
            // First, set the assigned staff back to Available (if any staff was assigned)
            pst = con.prepareStatement("UPDATE staff_core SET availability='Available' WHERE stf_id = (SELECT stf_id FROM damage_recording_infra WHERE dri_id=? AND stf_id IS NOT NULL)");
            pst.setInt(1, dri_id);
            pst.executeUpdate();
            
            // Then delete related damage_repair records
            pst = con.prepareStatement("DELETE FROM damage_repair WHERE dri_id=?");
            pst.setInt(1, dri_id);
            pst.executeUpdate();
            
            // Finally delete the damage_recording_infra record
            pst = con.prepareStatement("DELETE FROM damage_recording_infra WHERE dri_id=?");
            pst.setInt(1, dri_id);
            pst.executeUpdate();
            con.close();
            response.sendRedirect("damage_recording.jsp");
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
                       <td style="width:calc(100vw - 350px)" class="d-flex align-items-center">
                        <div style="width:100%;display:flex;justify-content:center;flex-direction:column;align-items:center">
                            <div class="d-flex" style="width:80%;margin-top:40px">
                                <div style="font-family:arial;font-size:28px;font-family:arial">
                                    Damage Recording
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
                                            <td class="fw-bold">Damage Details</td>
                                            <td class="fw-bold">Cause of Damage</td>
                                            <td class="fw-bold">Date Recorded</td>
                                            <td class="fw-bold">Data Staff Assigned</td>
                                            <td class="fw-bold">Staff</td>
                                            <td class="fw-bold">Infrastructure</td>
                                            <td class="fw-bold text-center">Action</td>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <%
                                            try{
                                                Connection con;
                                                ResultSet rs;
                                                
                                                Class.forName("com.mysql.jdbc.Driver");
                                                con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");

                                                String query = "SELECT dri.dri_id, dri.damage_details, dri.cause_of_damage, dri.date_recorded, dri.date_staff_assigned, dri.stf_id, dri.inf_id, " +
                                                                "i.location AS infrastructure, " +
                                                                "CONCAT(s.staff_fname, ' ', s.staff_lname) AS staff_name " +
                                                                "FROM damage_recording_infra dri " +
                                                                "LEFT JOIN infrastructure_core i ON dri.inf_id = i.inf_id " +
                                                                "LEFT JOIN staff_core s ON dri.stf_id = s.stf_id " +
                                                                "ORDER BY dri.dri_id DESC";
                                                Statement st = con.createStatement();
                                                rs = st.executeQuery(query);

                                                while(rs.next())
                                                {

                                                    int dri_id = rs.getInt("dri_id");
                                        %>
                                        <tr>
                                            <td><%= dri_id %></td>
                                            <td><%= rs.getString("damage_details")%></td>
                                            <td><%= rs.getString("cause_of_damage")%></td>
                                            <td><%= rs.getString("date_recorded")%></td>
                                            <td><%= rs.getString("date_staff_assigned")%></td>
                                            <td><%= rs.getString("staff_name")%></td>
                                            <td><%= rs.getString("infrastructure")%></td>
                                            <td>
                                                <div class="dropdown text-center">
                                                    <button class="btn btn-primary fw-bold" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                                                    Action
                                                    </button>
                                                    <ul class="dropdown-menu">
                                                        <li><a class="dropdown-item" href="damage_recording.jsp?action=getEdit&dri_id=<%= dri_id %>">Edit</a></li>
                                                        <li><a class="dropdown-item" href="damage_recording.jsp?action=delete&dri_id=<%= dri_id %>" onclick="return confirm('Are you sure you want to delete this record?');">Delete</a></li>
                                                    </ul>
                                                </div>
                                            </td>
                                        </tr>
                                        <%
                                                }
                                                con.close();
                                            }catch(Exception e) {
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

            <!--Add Modal-->
            <div class="modal fade" id="addModal" tabindex="-1" aria-labelledby="addModalLabel" aria-hidden="true">
              <div class="modal-dialog">
                <div class="modal-content">
                  <div class="modal-header">
                    <h1 class="modal-title fs-5" id="addModalLabel">Add Damage Recording</h1>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                  </div>
                  <div class="modal-body">
                    <form action="damage_recording.jsp" method="POST">
                        <input type="hidden" name="action" value="insert">
                        <div class="mb-3">
                            <label for="damage_details_add" class="form-label">Damage Details</label>
                            <input type="text" class="form-control" id="damage_details_add" name="damage_details_add">
                        </div>
                        <div class="mb-3">
                            <label for="cause_of_damage_add" class="form-label">Cause of Damage</label>
                            <input type="text" class="form-control" id="cause_of_damage_add" name="cause_of_damage_add">
                        </div>
                        <div class="mb-3">
                            <label for="date_recorded_add" class="form-label">Date Recorded</label>
                            <input type="date" class="form-control" id="date_recorded_add" name="date_recorded_add" required>
                        </div>
                        <div class="mb-3">
                            <label for="date_staff_assigned_add" class="form-label">Date Staff Assigned (Optional)</label>
                            <input type="date" class="form-control" id="date_staff_assigned_add" name="date_staff_assigned_add">
                        </div>
                        <div class="mb-3">
                            <label for="stf_id_add" class="form-label">Staff (Optional)</label>
                            <select class="form-select" id="stf_id_add" name="stf_id_add">
                                <option value="">Select Available Staff</option>
                                <%
                                    Connection con2;
                                    Statement st2;
                                    ResultSet rs2;
                                    
                                    Class.forName("com.mysql.jdbc.Driver");
                                    con2 = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
                                    st2 = con2.createStatement();
                                    rs2 = st2.executeQuery("SELECT s.stf_id, CONCAT(staff_fname, ' ', staff_lname) AS staff_name " +
                                                          "FROM staff_core s " +
                                                          "WHERE availability = 'Available' " +
                                                          "ORDER BY staff_fname");
                                    
                                    while(rs2.next()){
                                        int stf_id = rs2.getInt("stf_id");
                                        String staff_name = rs2.getString("staff_name");
                                %>
                                    <option value="<%= stf_id%>"><%= staff_name %></option>
                                <%
                                    }
                                    con2.close();
                                %>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label for="inf_id_add" class="form-label">Infrastructure</label>
                            <select class="form-select" id="inf_id_add" name="inf_id_add" required>
                                <option value="">Select Infrastructure</option>
                                <%
                                    Connection con3;
                                    Statement st3;
                                    ResultSet rs3;
                                    
                                    Class.forName("com.mysql.jdbc.Driver");
                                    con3 = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
                                    st3 = con3.createStatement();
                                    rs3 = st3.executeQuery("SELECT i.inf_id,  i.location " +
                                                          "FROM infrastructure_core i " +
                                                          "WHERE status = 'No need repair' " +
                                                          "ORDER BY i.location");
                                    
                                    while(rs3.next()){
                                        int inf_id = rs3.getInt("inf_id");
                                        String location = rs3.getString("location");
                                %>
                                    <option value="<%= inf_id%>"><%= location %></option>
                                <%
                                    }
                                    con3.close();
                                %>
                            </select>
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
                            <h1 class="modal-title fs-5" id="editModalLabel">Edit Damage Recording</h1>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <form action="damage_recording.jsp" method="POST">
                                <input type="hidden" name="action" value="submitEdit">
                                <input type="hidden" name="dri_id_edit" value="<%= dri_id_edit %>">
                                <div class="mb-3">
                                    <label for="damage_details_edit" class="form-label">Damage Details</label>
                                    <input type="text" class="form-control" id="damage_details_edit" name="damage_details_edit" value="<%= damage_details_edit %>">
                                </div>
                                <div class="mb-3">
                                    <label for="cause_of_damage_edit" class="form-label">Cause of Damage</label>
                                    <input type="text" class="form-control" id="cause_of_damage_edit" name="cause_of_damage_edit" value="<%= cause_of_damage_edit %>">
                                </div>
                                <div class="mb-3">
                                    <label for="date_recorded_edit" class="form-label">Damage Recorded</label>
                                    <input type="date" class="form-control" id="date_recorded_edit" name="date_recorded_edit" value="<%= date_recorded_edit %>">
                                </div>
                                <div class="mb-3">
                                    <label for="date_staff_assigned_edit" class="form-label">Damage Staff Assigned (Optional)</label>
                                    <input type="date" class="form-control" id="date_staff_assigned_edit" name="date_staff_assigned_edit" value="<%= date_staff_assigned_edit %>">
                                </div>
                                <div class="mb-3">
                                    <label for="stf_id_edit" class="form-label">Staff (Optional)</label>
                                    <select class="form-select" id="stf_id_edit" name="stf_id_edit">
                                        <option value="">No Staff Assigned</option>
                                        <%
                                            Connection con4;
                                            Statement st4;
                                            ResultSet rs4;
                                            int currentStf = stf_id_edit;

                                            Class.forName("com.mysql.jdbc.Driver");
                                            con4 = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
                                            st4 = con4.createStatement();
                                            rs4 = st4.executeQuery("SELECT s.stf_id, CONCAT(staff_fname, ' ', staff_lname) AS staff_name " +
                                                          "FROM staff_core s " +
                                                          "WHERE availability = 'Available' OR stf_id=" + currentStf +
                                                          " ORDER BY staff_fname");
                                    
                                            while(rs4.next()){
                                                int stf_id = rs4.getInt("stf_id");
                                                String staff_name = rs4.getString("staff_name");
                                        %>
                                            <option value="<%= stf_id %>" <%= (stf_id == currentStf) ? "selected" : "" %>><%= staff_name %></option>
                                        <%
                                            }
                                            con4.close();
                                        %>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label for="inf_id_edit" class="form-label">Infrastructure</label>
                                    <select class="form-select" id="inf_id_edit" name="inf_id_edit" required>
                                        <%
                                            Connection con5;
                                            Statement st5;
                                            ResultSet rs5;
                                            int currentInf = inf_id_edit;

                                            Class.forName("com.mysql.jdbc.Driver");
                                            con5 = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
                                            st5 = con5.createStatement();
                                            rs5 = st5.executeQuery("SELECT i.inf_id,  i.location " +
                                                                   "FROM infrastructure_core i " +
                                                                   "WHERE status = 'No need repair' OR inf_id=" + currentInf +
                                                                   " ORDER BY i.location");
                                    
                                            while(rs5.next()){
                                                int inf_id = rs5.getInt("inf_id");
                                                String location = rs5.getString("location");
                                        %>
                                            <option value="<%= inf_id %>" <%= (inf_id == currentInf) ? "selected" : "" %>><%= location %></option>
                                        <%
                                            }
                                            con5.close();
                                        %>
                                    </select>
                                </div>
                                <button type="submit" class="btn btn-primary">Submit</button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
            
        </body>
    </html>