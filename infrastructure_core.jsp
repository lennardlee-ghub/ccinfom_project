    
    <%@page import="java.sql.*" %>

    <% 


        //global variables for editing

        String location_edit = "";
        String status_edit = "";
        String type_of_building_edit = "";
        int inf_id_edit = 0;
        int boff_id_edit = 0;

        //for inserting a record logic
        String action = request.getParameter("action");

        if("insert".equals(action)){

            //modal insert variables
            String location_add = request.getParameter("location_add"); 
            String type_of_building_add = request.getParameter("type_of_building_add");
            String status_add = request.getParameter("status_add");

            //connection
            Connection con = null;
            PreparedStatement pst = null;
            ResultSet rs = null; 

            //insert statement
            try {
                Class.forName("com.mysql.jdbc.Driver");
                con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
                pst = con.prepareStatement("INSERT INTO infrastructure_core(location, type_of_infra, status) VALUES(?,?,?)");
                pst.setString(1, location_add);
                pst.setString(2, type_of_building_add);
                pst.setString(3, status_add);
                pst.executeUpdate();
            } catch (Exception e) {
                e.printStackTrace();
            }finally {
                // CLOSE EVERYTHING HERE - THIS IS THE MOST IMPORTANT PART!
                try {
                    if (pst != null) pst.close();
                } catch(Exception e) {
                    e.printStackTrace();
                }
                
                try {
                    if (con != null) con.close();
                } catch(Exception e) {
                    e.printStackTrace();
                }
            }

            //getting the latest inf_id
            Connection con_boff = null;
            PreparedStatement pst_boff = null;
            ResultSet rs_boff = null; 

            try {

                Class.forName("com.mysql.jdbc.Driver");
                con_boff = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");

                String query_boff = "SELECT * FROM infrastructure_core ORDER BY inf_id DESC LIMIT 1";
                Statement st = con_boff.createStatement();
                rs_boff = st.executeQuery(query_boff);
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                // CLOSE EVERYTHING HERE - THIS IS THE MOST IMPORTANT PART!
                try {
                    if (pst_boff != null) pst_boff.close();
                } catch(Exception e) {
                    e.printStackTrace();
                }
                
                try {
                    if (con_boff != null) con.close();
                } catch(Exception e) {
                    e.printStackTrace();
                }
            }

            //check if it exist
            String boff_id_add = request.getParameter("boff_id_add"); 

            if(rs_boff.next() && "none".equals(boff_id_add) == false){

                //variables
                //infrastructure id
                int inf_id = rs_boff.getInt("inf_id");

                //boff_id
                int boff_id_converted = Integer.parseInt(boff_id_add);

                //insert into barangay_officials_infra
                //connection
                Connection con_boff_insert = null;
                PreparedStatement pst_boff_insert = null;


                try{
                    //insert statement to barangay official id 
                    Class.forName("com.mysql.jdbc.Driver");
                    con_boff_insert = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
                    pst_boff_insert = con_boff_insert.prepareStatement("INSERT INTO barangay_officials_infra(boff_id, inf_id) VALUES(?,?)");
                    pst_boff_insert.setInt(1, boff_id_converted);
                    pst_boff_insert.setInt(2, inf_id);
                    pst_boff_insert.executeUpdate();
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    // CLOSE EVERYTHING HERE - THIS IS THE MOST IMPORTANT PART!
                    try {
                        if (pst_boff_insert != null) pst_boff_insert.close();
                    } catch(Exception e) {
                        e.printStackTrace();
                    }
                    
                    try {
                        if (con_boff_insert != null) con_boff_insert.close();
                    } catch(Exception e) {
                        e.printStackTrace();
                    }
                }
    


            }

        }
        else if("getEdit".equals(action)){


            //getting the inf_id which is the foreign key
            String inf_id_str = request.getParameter("inf_id");

            //converting to int
            int inf_id = Integer.parseInt(inf_id_str);

            //connection
            Connection con = null;
            PreparedStatement pst = null;
            ResultSet rs = null;

            try{

                //get the updated table 
                Class.forName("com.mysql.jdbc.Driver");
                con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
                pst = con.prepareStatement(
                    "SELECT *, barangay_officials_core.boff_id AS barangay_officials_core_boff_id " +
                    "FROM infrastructure_core " +
                    "LEFT JOIN barangay_officials_infra ON infrastructure_core.inf_id = barangay_officials_infra.inf_id " +
                    "LEFT JOIN barangay_officials_core ON barangay_officials_infra.boff_id = barangay_officials_core.boff_id " +
                    "WHERE infrastructure_core.inf_id = ?"
                );
                pst.setInt(1, inf_id);
                rs = pst.executeQuery();
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                // CLOSE EVERYTHING HERE - THIS IS THE MOST IMPORTANT PART!
                try {
                    if (pst != null) pst.close();
                } catch(Exception e) {
                    e.printStackTrace();
                }
                
                try {
                    if (con != null) con.close();
                } catch(Exception e) {
                    e.printStackTrace();
                }
            }

            if(rs.next()){

                location_edit = rs.getString("location");
                type_of_building_edit = rs.getString("type_of_infra");
                status_edit = rs.getString("status");
                inf_id_edit = rs.getInt("inf_id");

                //official name
                boff_id_edit = rs.getInt("barangay_officials_core_boff_id");
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

            // 3 possibilities
            // - if none to meron  (add)
            // - if meron na and still edit to meron then (edit) DONE
            // - if meron na but changed to none (delete)

            //modal insert variables
            location_edit = request.getParameter("location_edit"); 
            type_of_building_edit = request.getParameter("type_of_building_edit");
            status_edit = request.getParameter("status_edit");
            String inf_id_hidden_str = request.getParameter("inf_id_hidden");
            //parsing to int
            int inf_id_hidden = Integer.parseInt(inf_id_hidden_str);

            //boff_id
            String boff_id_edit_str = request.getParameter("boff_id_edit");
            Integer boff_id_edit_int = null; 

            if (boff_id_edit_str != null && !boff_id_edit_str.equals("none")) {
                boff_id_edit_int = Integer.parseInt(boff_id_edit_str);
            }

            //connection
            Connection con = null;
            PreparedStatement pst = null;
            ResultSet rs = null; 

            try{

                //submit edit statement
                Class.forName("com.mysql.jdbc.Driver");
                con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
                pst = con.prepareStatement("UPDATE infrastructure_core SET location=?, type_of_infra=?, status=? WHERE inf_id=?");

                pst.setString(1, location_edit);
                pst.setString(2, type_of_building_edit);
                pst.setString(3, status_edit);
                pst.setInt(4, inf_id_hidden);
                pst.executeUpdate();
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                // CLOSE EVERYTHING HERE - THIS IS THE MOST IMPORTANT PART!
                try {
                    if (pst != null) pst.close();
                } catch(Exception e) {
                    e.printStackTrace();
                }
                
                try {
                    if (con != null) con.close();
                } catch(Exception e) {
                    e.printStackTrace();
                }
            }
 

            //THIS MEANS THAT THE CURRENT INFRA HAS A BARANGAY OFFICIAL
            if(boff_id_edit_int != null){

                    //we need to select and check wether it had a previous barangay or not
                    //connection
                    Connection con_chk_boff = null;
                    PreparedStatement pst_chk_boff = null;
                    ResultSet rs_chk_boff = null; 

                    try{
      
                        //get the updated table 
                        Class.forName("com.mysql.jdbc.Driver");
                        con_chk_boff = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
                        pst_chk_boff = con_chk_boff.prepareStatement("SELECT * FROM barangay_officials_infra WHERE inf_id =?");
                        pst_chk_boff.setInt(1, inf_id_hidden);
                        rs_chk_boff = pst_chk_boff.executeQuery();

                    } catch(Exception e) {
                        e.printStackTrace();
                    } finally {
                        // CLOSE EVERYTHING HERE - THIS IS THE MOST IMPORTANT PART!
                        try {
                            if (pst_chk_boff != null) pst_chk_boff.close();
                        } catch(Exception e) {
                            e.printStackTrace();
                        }
                        
                        try {
                            if (con_chk_boff != null) con_chk_boff.close();
                        } catch(Exception e) {
                            e.printStackTrace();
                        }
                    }

                    //IT MEANS NA OLD RECORD MERON SIYA
                    if(rs_chk_boff.next()){


                        //connection
                        Connection con_edit = null;
                        PreparedStatement pst_edit = null;
                        ResultSet rs_edit = null;

                        try{
         
                            //submit edit statement
                            Class.forName("com.mysql.jdbc.Driver");
                            con_edit = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
                            pst_edit = con_edit.prepareStatement("UPDATE barangay_officials_infra SET boff_id=? WHERE inf_id=?");
            
                            //question is what if it has the same infrastructure
                            pst_edit.setInt(1, boff_id_edit_int);
                            pst_edit.setInt(2, inf_id_hidden);
                            pst_edit.executeUpdate(); 
                        } catch(Exception e) {
                            e.printStackTrace();
                        } finally {
                            // CLOSE EVERYTHING HERE - THIS IS THE MOST IMPORTANT PART!
                            try {
                                if (pst_edit != null) pst_edit.close();
                            } catch(Exception e) {
                                e.printStackTrace();
                            }
                            
                            try {
                                if (con_edit != null) con_edit.close();
                            } catch(Exception e) {
                                e.printStackTrace();
                            }
                        }

 
                    }else{
                        //IT MEANS IT DOESNT EXIST YET BUT THEY ADDED
                        //connection

                        Connection con_boff_insert2 = null;
                        PreparedStatement pst_boff_insert2 = null;

                        try{
            
                            //insert statement to barangay official id 
                            Class.forName("com.mysql.jdbc.Driver");
                            con_boff_insert2= DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
                            pst_boff_insert2 = con_boff_insert2.prepareStatement("INSERT INTO barangay_officials_infra(boff_id, inf_id) VALUES(?,?)");
                            pst_boff_insert2.setInt(1, boff_id_edit_int);
                            pst_boff_insert2.setInt(2, inf_id_hidden);
                            pst_boff_insert2.executeUpdate();
                        } catch(Exception e) {
                            e.printStackTrace();
                        } finally {

                            // CLOSE EVERYTHING HERE - THIS IS THE MOST IMPORTANT PART!
                            try {
                                if (pst_boff_insert2 != null) pst_boff_insert2.close();
                            } catch(Exception e) {
                                e.printStackTrace();
                            }
                            
                            try {
                                if (con_boff_insert2 != null) con_boff_insert2.close();
                            } catch(Exception e) {
                                e.printStackTrace();
                            }
                        }
                     
                    }
                


            }else{
                //it means walang infrastructure
                //so we will delete it if walang infrastructure

                //we need to select and check wether it had a previous barangay or not
                //connection
                Connection con_chk_boff2 = null;
                PreparedStatement pst_chk_boff2 = null;
                ResultSet rs_chk_boff2 = null; 

                try{
        
                    //get the updated table 
                    Class.forName("com.mysql.jdbc.Driver");
                    con_chk_boff2 = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
                    pst_chk_boff2 = con_chk_boff2.prepareStatement("SELECT * FROM barangay_officials_infra WHERE inf_id =?");
                    pst_chk_boff2.setInt(1, inf_id_hidden);
                    rs_chk_boff2 = pst_chk_boff2.executeQuery();
                }catch(Exception e){
                    e.printStackTrace();
                } try {
                    if (rs_chk_boff2 != null) pst_chk_boff2.close();
                } catch(Exception e) {
                    e.printStackTrace();
                }try {
                    if (con_chk_boff2 != null) pst_chk_boff2.close();
                } catch(Exception e) {
                    e.printStackTrace();
                }
        
    
                //IT MEANS NA OLD RECORD MERON SIYA SO NADELETE
                if(rs_chk_boff2.next()){
                    //so we have to delete it if we disassing it from meron to none
                    Connection con_del2 = null;
                    PreparedStatement pst_del2 = null;
                    ResultSet rs_del2 = null;

                    try{
   
                        Class.forName("com.mysql.jdbc.Driver");
                        con_del2 = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
                        pst_del2 = con_del2.prepareStatement("DELETE FROM barangay_officials_infra WHERE inf_id=?");
                        pst_del2.setInt(1, inf_id_hidden);
                        pst_del2.executeUpdate();

                    }catch(Exception e){
                        e.printStackTrace();
                    } finally {
                        // CLOSE EVERYTHING HERE - THIS IS THE MOST IMPORTANT PART!
                        try {
                            if (pst_del2 != null) pst_del2.close();
                        } catch(Exception e) {
                            e.printStackTrace();
                        }
                        
                        try {
                            if (con_del2 != null) con_del2.close();
                        } catch(Exception e) {
                            e.printStackTrace();
                        }
                    }
         
                }
            }
   
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
            Connection con = null;
            PreparedStatement pst = null;
            ResultSet rs = null;

            try{

                String inf_id_delete_str = request.getParameter("inf_id");
                //parsing to int
                int inf_id_delete = Integer.parseInt(inf_id_delete_str);
    
                Class.forName("com.mysql.jdbc.Driver");
                con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
                pst = con.prepareStatement("DELETE FROM infrastructure_core WHERE inf_id=?");
                pst.setInt(1, inf_id_delete);
                pst.executeUpdate();
            } catch (Exception e) {
                e.printStackTrace();
            }finally {
                // CLOSE EVERYTHING HERE - THIS IS THE MOST IMPORTANT PART!
                try {
                    if (pst != null) pst.close();
                } catch(Exception e) {
                    e.printStackTrace();
                }
                
                try {
                    if (con != null) con.close();
                } catch(Exception e) {
                    e.printStackTrace();
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

                                                <td class="fw-bold">
                                                    Barangay Official
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
                                    
                                        String query = "SELECT infrastructure_core.inf_id as inf_id, " +
                                                            "infrastructure_core.location as location, " +
                                                            "infrastructure_core.type_of_infra as type_of_infra, " +
                                                            "infrastructure_core.status as status, " +
                                                            "barangay_officials_core.official_fname as official_fname, " +
                                                            "barangay_officials_core.official_lname as official_lname, " +
                                                            "barangay_officials_core.official_midname as official_midname " +
                                                        "FROM infrastructure_core " +
                                                        "LEFT JOIN barangay_officials_infra " +
                                                        "ON infrastructure_core.inf_id = barangay_officials_infra.inf_id " +
                                                        "LEFT JOIN barangay_officials_core " +
                                                        "ON barangay_officials_infra.boff_id = barangay_officials_core.boff_id" +
                                                        " ORDER BY infrastructure_core.location ASC"; ;

                                        Statement st = con.createStatement();
                                        rs = st.executeQuery(query);
                                        
                                        while(rs.next())
                                        {
                                            String status = rs.getString("status");
                                            String type_of_infra = rs.getString("type_of_infra");
                                            String location = rs.getString("location");
                                            int inf_id = rs.getInt("inf_id");
                                    
                                            //official name
                                            String official_fname = rs.getString("official_fname");
                                            String official_lname = rs.getString("official_lname");
                                            String official_midname = rs.getString("official_midname");
                                            
                                            String fullName = "Not Assigned";
                                            if (official_fname != null && official_lname != null) {
                                                String midInit = (official_midname != null) ? official_midname + ". " : "";
                                                fullName = official_fname + " " + midInit + official_lname;
                                            }

                                    %>
                                    <tr>
                                        <td><%=location%></td>
                                        <td><%=type_of_infra%></td>
                                        <td><%=status%></td>
                                        <td><%=fullName%></td>
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
                                    <form>
                                        <div class="modal-header">
                                        <h5 class="modal-title" id="exampleModalLabel">Add infrastructure</h5>
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
                                            
                                            <div class="mb-3">
                                                <label for="recipient-name" class="col-form-label">Barangay Official:</label>
                                                    <select name="boff_id_add" class="form-select" id="boff_id_add">
                                                    <option value="none">None</option>
                                               <%

                                                Connection con2;
                                                PreparedStatement pat2;
                                                ResultSet rs2;     
                                                
                                                Class.forName("com.mysql.jdbc.Driver");
                                                con2 = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
                          
                                                String query2 = "SELECT barangay_officials_core.official_fname as official_fname, " +
                                                                       "barangay_officials_core.official_lname as official_lname, " +
                                                                       "barangay_officials_core.official_midname as official_midname, " +
                                                                       "barangay_officials_core.boff_id as boff_id " +
                                                        "FROM barangay_officials_core";

                                                Statement st2 = con2.createStatement();
                                                rs2 = st2.executeQuery(query2);
                                                        
                                                while(rs2.next())
                                                {
                                            
                                                    //official name
                                                    String official_fname = rs2.getString("official_fname");
                                                    String official_lname = rs2.getString("official_lname");
                                                    String official_midname = rs2.getString("official_midname");
                                                    int boff_id = rs2.getInt("boff_id");

                                                    String fullName = "Not Assigned";
                                                    if (official_fname != null && official_lname != null) {
                                                        String midInit = (official_midname != null) ? official_midname + ". " : "";
                                                        fullName = official_fname + " " + midInit + official_lname;
                                                    }
                                                    
                                                %>
                                                    <option value="<%=boff_id%>"><%=fullName%></option>
                                                    
                                                <%
                                                    } 
                                                %>
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
                                    <form>
                                        <div class="modal-header">
                                            <h5 class="modal-title" id="exampleModalLabel">Edit infrastructure</h5>
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
                                            
                                            <div class="mb-3">
                                                <label for="recipient-name" class="col-form-label">Barangay Official:</label>
                                                    <select name="boff_id_edit" class="form-select" id="boff_id_edit">
                                                    <option value="none">None</option>
                                               <%

                                                Connection con4;
                                                PreparedStatement pat4;
                                                ResultSet rs4;     
                                                
                                                Class.forName("com.mysql.jdbc.Driver");
                                                con4 = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
                          
                                                String query4 = "SELECT barangay_officials_core.official_fname as official_fname, " +
                                                                       "barangay_officials_core.official_lname as official_lname, " +
                                                                       "barangay_officials_core.official_midname as official_midname, " +
                                                                       "barangay_officials_core.boff_id as boff_id " +
                                                        "FROM barangay_officials_core";

                                                Statement st4 = con4.createStatement();
                                                rs4 = st4.executeQuery(query4);
                                                        
                                                while(rs4.next())
                                                {
                                            
                                                    //official name
                                                    String official_fname = rs4.getString("official_fname");
                                                    String official_lname = rs4.getString("official_lname");
                                                    String official_midname = rs4.getString("official_midname");
                                                    int boff_id = rs4.getInt("boff_id");

                                                    String fullName = "Not Assigned";
                                                    if (official_fname != null && official_lname != null) {
                                                        String midInit = (official_midname != null) ? official_midname + ". " : "";
                                                        fullName = official_fname + " " + midInit + official_lname;
                                                    }
                                                    
                                                %>
                                                    <option value="<%=boff_id%>" <%= (boff_id_edit == boff_id) ? "selected" : "" %>><%=fullName%></option>
                                                    
                                                <%
                                                    } 
                                                %>
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