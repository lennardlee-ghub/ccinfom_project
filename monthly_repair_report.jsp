    
    <%@page import="java.sql.*" %>
    <% 

        String action = request.getParameter("action");
        String month_filter = "";
        String month_filter_backend = "";

        String xfilter = "";

        if("search".equals(action)){

            month_filter = request.getParameter("month_filter");
            if(month_filter != null && !month_filter.isEmpty())
            {
                month_filter_backend = month_filter;
                String month_start = month_filter + "-01";
                xfilter += " AND dr.date_end BETWEEN '" + month_start + "' AND LAST_DAY('" + month_start + "') ";
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
                                        Monthly Repair Reports
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
                                            Month: 
                                        </div>
                                        <input type="month" class="form-control" style="margin-left:15px" name="month_filter" id="month_filter" value="<%= month_filter_backend %>"/>
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
                                                    Damage Details
                                                </td>
    
                                                <td class="fw-bold">
                                                    Cause of Damage
                                                </td>

                                                <td class="fw-bold">
                                                    Date Repaired
                                                </td>

                                                <td class="fw-bold">
                                                    Item Used
                                                </td>

                                                <td class="fw-bold">
                                                    Quantity Used
                                                </td>
                                            </tr>
                                        </thead>
                                        <%
                                        Connection con;
                                        PreparedStatement pat;
                                        ResultSet rs; 
                                    
                                        Class.forName("com.mysql.jdbc.Driver");
                                        con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");


                           
                                        String query = "SELECT i.location AS infra_loc, " +
                                                       "dri.damage_details, " +
                                                       "dri.cause_of_damage, " +
                                                       "dr.date_end AS date_repaired, " +
                                                       "ic.item_name AS item_used, " +
                                                       "iu.quantity_used " +
                                                       "FROM damage_repair dr " +
                                                       "JOIN damage_recording_infra dri ON dri.dri_id = dr.dri_id " +
                                                       "JOIN infrastructure_core i ON i.inf_id = dri.inf_id " +
                                                       "JOIN inventory_usage iu ON iu.dr_id = dr.dr_id " +
                                                       "JOIN inventory_core ic ON ic.inv_id = iu.inv_id " +
                                                       "WHERE dr.status = 'Repaired'" + xfilter +
                                                       "ORDER BY dr.date_end DESC";

                                        Statement st = con.createStatement();
                                        rs = st.executeQuery(query);
                                        
                                        while(rs.next())
                                        {
                                            String location = rs.getString("infra_loc");
                                            String damage_details = rs.getString("damage_details");
                                            String cause_of_damage = rs.getString("cause_of_damage");
                                            String date_repaired = rs.getString("date_repaired");
                                            String item_used = rs.getString("item_used");
                                            String quantity_used = rs.getString("quantity_used");

                                            if (date_repaired != null && !date_repaired.equals(""))
                                            {
                                                java.text.SimpleDateFormat fromDB = new java.text.SimpleDateFormat("yyyy-MM-dd");
                                                java.text.SimpleDateFormat toDisplay = new java.text.SimpleDateFormat("MM/dd/yyyy");
                                                java.util.Date parsed2 = fromDB.parse(date_repaired);
                                                date_repaired = toDisplay.format(parsed2);  // overwrite the same variable
                                            }
                                            else
                                            {
                                               date_repaired = "N/A"; 
                                            }
                                    %>
                                    <tr>
                                        <td><%= location %></td>
                                        <td><%= damage_details %></td>
                                        <td><%= cause_of_damage %></td>
                                        <td><%= date_repaired %></td>
                                        <td><%= item_used %></td>
                                        <td><%= quantity_used %></td>
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