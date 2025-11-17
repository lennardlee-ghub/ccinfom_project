    
    <%@page import="java.sql.*" %>
    <% 

        String action = request.getParameter("action");
        String status_filter = "";
        String date_start_filter = "";
        String date_end_filter = "";
        String date_start_filter_backend   = "";
        String date_end_filter_backend     = "";

        String xfilter = "";

        if("search".equals(action)){
            status_filter = request.getParameter("status_filter"); 

            //so when submit it is still active
            date_start_filter = request.getParameter("date_start_filter");
            date_start_filter_backend = request.getParameter("date_start_filter");

            //so when submit it can still be viewed
            date_end_filter = request.getParameter("date_end_filter");
            date_end_filter_backend = request.getParameter("date_end_filter");

            //filtering the status
            if("All".equals(status_filter) == false){
                xfilter  += " AND i.status = '" + status_filter + "' ";
            }

            //filtering the date_start
            if (date_start_filter != null && !date_start_filter.isEmpty()) {
                xfilter += " AND latest_damage.date_recorded >= '" + date_start_filter + "'";
            }

            //filtering the date_end
            if (date_end_filter != null && !date_end_filter.isEmpty()) {
                xfilter += " AND dr.date_end <= '" + date_end_filter + "'";
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
                                    <div style="font-family:arial;font-size:28px;font-family:arial;display:flex;flex-direction:row">
                                        Infrastructure Reports
                                    </div>

                                    <button class="btn btn-primary fw-bold" style="margin-left:auto" type="submit" name="action" value="search">
                                        Search
                                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-search" viewBox="0 0 16 16">
                                            <path d="M11.742 10.344a6.5 6.5 0 1 0-1.397 1.398h-.001q.044.06.098.115l3.85 3.85a1 1 0 0 0 1.415-1.414l-3.85-3.85a1 1 0 0 0-.115-.1zM12 6.5a5.5 5.5 0 1 1-11 0 5.5 5.5 0 0 1 11 0"/>
                                        </svg>
                                    </button>
                                </div>
                        
                                <div style="display:flex;flex-direction:row;justify-content:flex-start;width:80%;margin-top:20px">

                                    <div style="display:flex;flex-direction:row">
                                    
                                        <div style="font-size:24px">
                                            Status: 
                                        </div>

                                        <select class="form-select" style="margin-left:15px" name="status_filter" id="status_filter">
                                            <option <%= "All".equals(status_filter) ? "selected" : "" %>>All</option>
                                            <option <%= "No need repair".equals(status_filter) ? "selected" : "" %>>No need repair</option>
                                            <option <%= "Damaged".equals(status_filter) ? "selected" : "" %>>Damaged</option>
                                            <option <%= "Repairing".equals(status_filter) ? "selected" : "" %>>Repairing</option>
                                        </select>

                                        <div style="font-size:24px;text-wrap:nowrap;margin-left:15px">
                                            Date Start:
                                        </div>
                                        <input type="date" class="form-control" style="margin-left:15px" name="date_start_filter" id="date_start_filter" value="<%=date_start_filter%>"/>

                                        <div style="font-size:24px;text-wrap:nowrap;margin-left:15px">
                                            Date End:
                                        </div>
                                        <input type="date" class="form-control" style="margin-left:15px" name="date_end_filter" id="date_end_filter" value="<%=date_end_filter%>"/>
                                    </div>
                                </div>

                                <div style="width:100%;display:flex;justify-content:center;margin-top:20px">
                                    <table class="table table-striped" style="width:80%">
                                        <thead>
                                            <tr>
                                                <td class="fw-bold">
                                                    Infrastructure Location
                                                </td>
    
                                                <td class="fw-bold">
                                                    Status
                                                </td>
    
                                                <td class="fw-bold">
                                                    Date of Recorded Damage
                                                </td>

                                                <td class="fw-bold">
                                                    Date Repaired
                                                </td>
                                            </tr>
                                        </thead>
                                        <%
                                        Connection con;
                                        PreparedStatement pat;
                                        ResultSet rs; 
                                    
                                        Class.forName("com.mysql.jdbc.Driver");
                                        con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");


                           
                                        String query = "SELECT i.inf_id as inf_id, " +
                                                    "i.location as location, " +
                                                    "i.status as status, " +
                                                    "latest_damage.dri_id as damage_recording_infra_dri_id, " +
                                                    "dr.dri_id as damage_repair_dri_id, " +
                                                    "latest_damage.date_recorded as date_recorded_damage, " +
                                                    "dr.date_end as date_finished_repair " +
                                                "FROM infrastructure_core i " +
                                                "LEFT JOIN ( " +
                                                    "SELECT dri.inf_id, dri.dri_id, dri.date_recorded " +
                                                    "FROM damage_recording_infra dri " +
                                                    "WHERE dri.date_recorded = ( " +
                                                        "SELECT MAX(dri2.date_recorded) " +
                                                        "FROM damage_recording_infra dri2 " +
                                                        "WHERE dri.inf_id = dri2.inf_id " +
                                                    ") " +
                                                ") latest_damage ON i.inf_id = latest_damage.inf_id " +
                                                "LEFT JOIN damage_repair dr " +
                                                "ON latest_damage.dri_id = dr.dri_id " +
                                                "WHERE true " + xfilter +
                                                " ORDER BY latest_damage.date_recorded DESC";

                                        Statement st = con.createStatement();
                                        rs = st.executeQuery(query);
                                        
                                        while(rs.next())
                                        {
                                            String status = rs.getString("status");
                                            String location = rs.getString("location");
                                            int inf_id = rs.getInt("inf_id");
                                            String date_damaged = rs.getString("date_recorded_damage");
                                            String date_repaired = rs.getString("date_finished_repair");

                                            if (date_damaged != null && !"".equals(date_damaged)) {

                                                java.text.SimpleDateFormat fromDB = new java.text.SimpleDateFormat("yyyy-MM-dd");
                                                java.text.SimpleDateFormat toDisplay = new java.text.SimpleDateFormat("MM/dd/yyyy");
                                                java.util.Date parsed = fromDB.parse(date_damaged);
                                                date_damaged = toDisplay.format(parsed);  // overwrite the same variable
                                            }else{
                                                date_damaged = "N/A";
                                            }
                                            
                                            if (date_repaired != null && !"".equals(date_repaired)) {

                                                java.text.SimpleDateFormat fromDB = new java.text.SimpleDateFormat("yyyy-MM-dd");
                                                java.text.SimpleDateFormat toDisplay = new java.text.SimpleDateFormat("MM/dd/yyyy");
                                                java.util.Date parsed2 = fromDB.parse(date_repaired);
                                                date_repaired = toDisplay.format(parsed2);  // overwrite the same variable
                                            }else{
                                                date_repaired = "N/A";
                                            }

                        

                                                                        
                                    %>
                                    <tr>
                                        <td><%=location%></td>
                                        <td><%=status%></td>
                                        <td><%=date_damaged%></td>
                                        <td><%=date_repaired%></td>
                                    </tr>
                                    <%
                                        }
                                    %>
    
                                    </table>
                                </div>
                            </div>
                        </form>
                    </td>
                </tr>
            </table>


        </body>
    </html>