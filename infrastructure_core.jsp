<%@page import="java.sql.*" %>

    <% 


        //global variables for editing

        String location_edit = "";
        String status_edit = "";
        String type_of_building_edit = "";
        int inf_id_edit = 0;

        //for inserting a record logic
        String action = request.getParameter("action");

        if("insert".equals(action)){
            //modal insert variables
            String location_add = request.getParameter("location_add"); 
            String status_add = request.getParameter("status_add");
            String type_of_building_add = request.getParameter("type_of_building_add");

            //connection
            Connection con;
            PreparedStatement pst;
            ResultSet rs; 

            //insert statement
            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
            pst = con.prepareStatement("insert into infrastructure_core(location,status,type_of_building)values(?,?,?)");
            pst.setString(1, location_add);
            pst.setString(2, status_add);
            pst.setString(3, type_of_building_add);
            pst.executeUpdate();
            response.sendRedirect("infrastructure_core.jsp");
        }
        else if("getEdit".equals(action)){


            //getting the inf_id which is the foreign key
            String inf_id_str = request.getParameter("inf_id");

            //converting to int
            int inf_id = Integer.parseInt(inf_id_str);

            //connection
            Connection con;
            PreparedStatement pst;
            ResultSet rs; 

            //get the updated table 
            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
            pst = con.prepareStatement("SELECT * FROM infrastructure_core WHERE inf_id=?");
            pst.setInt(1, inf_id);
            rs = pst.executeQuery();

            if(rs.next()){
                location_edit = rs.getString("location");
                type_of_building_edit = rs.getString("type_of_infra");
                status_edit = rs.getString("status");
                inf_id_edit = rs.getInt("inf_id");
            }

            %>

            <script>
                //hide the modal
                document.addEventListener('DOMContentLoaded', function() {
                    var editModal = new bootstrap.Modal(document.getElementById('editModal'));
                    editModal.show();
                });
            </script>


            <%

        }else if("submitEdit".equals(action)){
            

            //modal insert variables
            location_edit = request.getParameter("location_edit"); 
            type_of_building_edit = request.getParameter("type_of_building_edit");
            status_edit = request.getParameter("status_edit");
            String inf_id_hidden_str = request.getParameter("inf_id_hidden");
            //parsing to int
            int inf_id_hidden = Integer.parseInt(inf_id_hidden_str);

            //connection
            Connection con;
            PreparedStatement pst;
            ResultSet rs; 

            //submit edit statement

            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
            pst = con.prepareStatement("UPDATE infrastructure_core SET location=?, type_of_infra=?, status=? WHERE inf_id=?");
            pst.setString(1, location_edit);
            pst.setString(2, type_of_building_edit);
            pst.setString(3, status_edit);
            pst.setInt(4, inf_id_hidden);
            pst.executeUpdate();
            response.sendRedirect("infrastructure_core.jsp");

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
            //get inf_id for deletion
            int inf_id = Integer.parseInt(request.getParameter("inf_id"));

            //connection
            Connection con;
            PreparedStatement pst;

            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
            pst = con.prepareStatement("delete from infrastructure_core where inf_id=?");
            pst.setInt(1, inf_id);
            pst.executeUpdate();
            response.sendRedirect("infrastructure_core.jsp");
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

                        <form  method="POST" action="" style="width:100%;height:100%">

                            <div style="width:100%;display:flex;justify-content:center;flex-direction:column;align-items:center">
                                <div class="d-flex" style="width:80%;margin-top:40px">
                                    <div style="font-family:arial;font-size:28px;font-family:arial">
                                        Infrastructure Record
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
                                                    Location
                                                </td>
    
                                                <td class="fw-bold">
                                                    Type of Location
                                                </td>
    
                                                <td class="fw-bold">
                                                    Status
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

                                            String query = "select * FROM infrastructure_core";
                                            Statement st = con.createStatement();
                                            rs = st.executeQuery(query);

                                            while(rs.next())
                                            {
                                                String status = rs.getString("status");
                                                String type_of_infra = rs.getString("type_of_infra");
                                                String location = rs.getString("location");
                                                int inf_id = rs.getInt("inf_id");

                                        %>
                                        <tr>
                                            <td><%=rs.getString("location")%></td>
                                            <td><%=rs.getString("type_of_infra")%></td>
                                            <td><%=rs.getString("status")%></td>
                                            <td>
                                                <div class="dropdown text-center">
                                                    <button class="btn btn-primary fw-bold" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                                                    Action
                                                    </button>
                                                    <ul class="dropdown-menu">
                                                    <li><a class="dropdown-item" href="?action=getEdit&inf_id=<%=inf_id%>">Edit</a></li>
                                                    <li><a class="dropdown-item" href="?action=delete&inf_id=<%=inf_id%>">Delete</a></li>
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
                                    <form action="infrastructure_core.jsp" method="POST">
                                        <input type="hidden" name="action" value="insert">
                                        <div class="modal-header">
                                        <h1 class="modal-title fs-5" id="addModalLabel">Add Infrastructure Record</h1>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                      </div>
                                      <div class="modal-body">
                                        
                                            <div class="mb-3">
                                            <label for="recipient-name" class="col-form-label">Location:</label>
                                            <input type="text" name="location_add" id="location_add" class="form-control" id="recipient-name">
                                            </div>
                                            <div class="mb-3">
                                                <label for="recipient-name" class="col-form-label">Type of Building:</label>
                                                <select name="type_of_building_add" class="form-select" id="type_of_building_add">
                                                    <option>Building</option>
                                                    <option>Warehouse</option>
                                                    <option>House</option>
                                                    <option>Condominium</option>
                                                </select>
                                            </div>
                                            <div class="mb-3">
                                                <label for="recipient-name" class="col-form-label">Status:</label>
                                                <select name="status_add" class="form-select" id="status_add">
                                                    <option>No need repair</option>
                                                    <option>Damaged</option>
                                                    <option>Repairing</option>
                                                </select>
                                            </div>                        
                                    
                                        </div>
                                        <div class="modal-footer">
                                        <button type="button" class="btn btn-danger" type="button" data-bs-dismiss="modal">Close</button>
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
                                    <form action="infrastructure_core.jsp" method="POST">
                                        <input type="hidden" name="action" value="submitEdit">
                                        <input type="hidden" name="inf_id_edit" value="<%= inf_id_edit %>">
                                        <div class="modal-header">
                                            <h1 class="modal-title fs-5" id="editModalLabel">Edit Infrastructure Record</h1>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <div class="modal-body">
                                    
                                            <div class="mb-3">
                                            <label for="recipient-name" class="col-form-label">Location:</label>
                                            <input type="text" name="location_edit" id="location_edit" class="form-control" value="<%=location_edit%>" id="recipient-name">
                                            </div>
                                            <div class="mb-3">
                                                <label for="recipient-name" class="col-form-label">Type of Building:</label>
                                                <select name="type_of_building_edit" class="form-select" id="type_of_building_edit">
                                                    <option <%="Building".equals(type_of_building_edit) ? "selected" : ""%>>Building</option>
                                                    <option <%="Warehouse".equals(type_of_building_edit) ? "selected" : ""%>>Warehouse</option>
                                                    <option <%="House".equals(type_of_building_edit) ? "selected" : ""%>>House</option>
                                                    <option <%="Condominium".equals(type_of_building_edit) ? "selected" : ""%>>Condominium</option>
                                                </select>
                                            </div>
                                            <div class="mb-3">
                                                <label for="recipient-name" class="col-form-label">Status:</label>
                                                <select name="status_edit" class="form-select" id="status_edit">
                                                    <option <%="No need repair".equals(status_edit) ? "selected" : ""%>>No need repair</option>
                                                    <option <%="Damaged".equals(status_edit) ? "selected" : ""%>>Damaged</option>
                                                    <option <%="Repairing".equals(status_edit) ? "selected" : ""%>>Repairing</option>
                                                </select>
                                            </div>                        
                                    
                                        </div>

                                        <div class="modal-footer">
                                            <button type="button" class="btn btn-danger" type="button" data-bs-dismiss="modal">Close</button>
                                            <button class="btn btn-primary" type="submit" name="action" id="action" value="submitEdit">Update</button>

                                            <input type="hidden" name="inf_id_hidden" id="inf_id_hidden" value="<%=inf_id_edit%>">
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