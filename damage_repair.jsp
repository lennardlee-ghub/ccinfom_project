    
    <%@page import="java.sql.*" %>

    <% 
        // Global variables for editing
        int dr_id_edit = 0;
        String date_start_edit = "";
        String date_end_edit = "";
        String status_edit = "";
        int stf_id_edit = 0;
        int inf_id_edit = 0;

        // For inserting a record logic
        String action = request.getParameter("action");

        if("insert".equals(action)){
            // Modal insert variables
            String date_start_add = request.getParameter("date_start_add"); 
            String date_end_add = request.getParameter("date_end_add");
            String status_add = request.getParameter("status_add");
            String stf_id_add_str = request.getParameter("stf_id_add");
            String inf_id_add_str = request.getParameter("inf_id_add");
            
            int stf_id_add = Integer.parseInt(stf_id_add_str);
            int inf_id_add = Integer.parseInt(inf_id_add_str);

            // Connection
            Connection con;
            PreparedStatement pst;

            // Insert statement
            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
            pst = con.prepareStatement("INSERT INTO damage_repair(date_start, date_end, status, stf_id, inf_id) VALUES(?,?,?,?,?)");
            pst.setString(1, date_start_add);
            pst.setString(2, date_end_add);
            pst.setString(3, status_add);
            pst.setInt(4, stf_id_add);
            pst.setInt(5, inf_id_add);
            pst.executeUpdate();
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
        } else if("submitEdit".equals(action)){
            // Get parameters from edit form
            int dr_id = Integer.parseInt(request.getParameter("dr_id_edit"));
            String date_start = request.getParameter("date_start_edit");
            String date_end = request.getParameter("date_end_edit");
            String status = request.getParameter("status_edit");
            int stf_id = Integer.parseInt(request.getParameter("stf_id_edit"));
            int inf_id = Integer.parseInt(request.getParameter("inf_id_edit"));

            // Connection
            Connection con;
            PreparedStatement pst;

            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
            pst = con.prepareStatement("UPDATE damage_repair SET date_start=?, date_end=?, status=?, stf_id=?, inf_id=? WHERE dr_id=?");
            pst.setString(1, date_start);
            pst.setString(2, date_end);
            pst.setString(3, status);
            pst.setInt(4, stf_id);
            pst.setInt(5, inf_id);
            pst.setInt(6, dr_id);
            pst.executeUpdate();
            con.close();
            response.sendRedirect("damage_repair.jsp");
        } else if("delete".equals(action)){
            // Get dr_id for deletion
            int dr_id = Integer.parseInt(request.getParameter("dr_id"));

            // Connection
            Connection con;
            PreparedStatement pst;

            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
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
                                                              "JOIN infrastructure_core i ON dr.inf_id = i.inf_id " +
                                                              "JOIN staff_core s ON dr.stf_id = s.stf_id " +
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
                            <label for="inf_id_add" class="form-label">Infrastructure</label>
                            <select class="form-select" id="inf_id_add" name="inf_id_add" required>
                                <option value="">Select Infrastructure</option>
                                <%
                                    Connection con2;
                                    Statement st2;
                                    ResultSet rs2;
                                    
                                    Class.forName("com.mysql.jdbc.Driver");
                                    con2 = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
                                    st2 = con2.createStatement();
                                    rs2 = st2.executeQuery("SELECT inf_id, location FROM infrastructure_core ORDER BY location");
                                    
                                    while(rs2.next()){
                                %>
                                    <option value="<%= rs2.getInt("inf_id") %>"><%= rs2.getString("location") %></option>
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
                            <label for="stf_id_add" class="form-label">Assigned Staff</label>
                            <select class="form-select" id="stf_id_add" name="stf_id_add" required>
                                <option value="">Select Staff</option>
                                <%
                                    Connection con3;
                                    Statement st3;
                                    ResultSet rs3;
                                    
                                    Class.forName("com.mysql.jdbc.Driver");
                                    con3 = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
                                    st3 = con3.createStatement();
                                    rs3 = st3.executeQuery("SELECT stf_id, staff_fname, staff_lname FROM staff_core ORDER BY staff_lname");
                                    
                                    while(rs3.next()){
                                %>
                                    <option value="<%= rs3.getInt("stf_id") %>"><%= rs3.getString("staff_fname") + " " + rs3.getString("staff_lname") %></option>
                                <%
                                    }
                                    con3.close();
                                %>
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
                            <label for="inf_id_edit" class="form-label">Infrastructure</label>
                            <select class="form-select" id="inf_id_edit" name="inf_id_edit" required>
                                <%
                                    Connection con4;
                                    Statement st4;
                                    ResultSet rs4;
                                    
                                    Class.forName("com.mysql.jdbc.Driver");
                                    con4 = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
                                    st4 = con4.createStatement();
                                    rs4 = st4.executeQuery("SELECT inf_id, location FROM infrastructure_core ORDER BY location");
                                    
                                    while(rs4.next()){
                                        int inf_id_option = rs4.getInt("inf_id");
                                        String selected = (inf_id_option == inf_id_edit) ? "selected" : "";
                                %>
                                    <option value="<%= inf_id_option %>" <%= selected %>><%= rs4.getString("location") %></option>
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
                            <label for="stf_id_edit" class="form-label">Assigned Staff</label>
                            <select class="form-select" id="stf_id_edit" name="stf_id_edit" required>
                                <%
                                    Connection con5;
                                    Statement st5;
                                    ResultSet rs5;
                                    
                                    Class.forName("com.mysql.jdbc.Driver");
                                    con5 = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
                                    st5 = con5.createStatement();
                                    rs5 = st5.executeQuery("SELECT stf_id, staff_fname, staff_lname FROM staff_core ORDER BY staff_lname");
                                    
                                    while(rs5.next()){
                                        int stf_id_option = rs5.getInt("stf_id");
                                        String selected = (stf_id_option == stf_id_edit) ? "selected" : "";
                                %>
                                    <option value="<%= stf_id_option %>" <%= selected %>><%= rs5.getString("staff_fname") + " " + rs5.getString("staff_lname") %></option>
                                <%
                                    }
                                    con5.close();
                                %>
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