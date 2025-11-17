    
    <%@page import="java.sql.*" %>
    <% 

        String action = request.getParameter("action");
        String operation_filter = "";
        String date_start_filter = "";
        String date_end_filter = "";

        String xfilter_added = "";
        String xfilter_used = "";

        if("search".equals(action)){
            operation_filter = request.getParameter("operation_filter"); 

            //so when submit it is still active
            date_start_filter = request.getParameter("date_start_filter");

            //so when submit it can still be viewed
            date_end_filter = request.getParameter("date_end_filter");

            //filtering the date_start for Added items
            if (date_start_filter != null && !date_start_filter.isEmpty()) {
                xfilter_added += " AND ic.date_added >= '" + date_start_filter + "'";
                xfilter_used += " AND iu.date_used >= '" + date_start_filter + "'";
            }

            //filtering the date_end for Added items
            if (date_end_filter != null && !date_end_filter.isEmpty()) {
                xfilter_added += " AND ic.date_added <= '" + date_end_filter + "'";
                xfilter_used += " AND iu.date_used <= '" + date_end_filter + "'";
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
                                        Inventory Reports
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
                                            Operation: 
                                        </div>

                                        <select class="form-select" style="margin-left:15px" name="operation_filter" id="operation_filter">
                                            <option <%= "All".equals(operation_filter) ? "selected" : "" %>>All</option>
                                            <option <%= "Added".equals(operation_filter) ? "selected" : "" %>>Added</option>
                                            <option <%= "Used".equals(operation_filter) ? "selected" : "" %>>Used</option>
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
                                                    Item Name
                                                </td>
    
                                                <td class="fw-bold">
                                                    Operation
                                                </td>
    
                                                <td class="fw-bold">
                                                    Quantity
                                                </td>

                                                <td class="fw-bold">
                                                    Category
                                                </td>

                                                <td class="fw-bold">
                                                    Date
                                                </td>
                                            </tr>
                                        </thead>
                                        <%
                                        Connection con;
                                        Statement st;
                                        ResultSet rs; 
                                    
                                        Class.forName("com.mysql.jdbc.Driver");
                                        con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");

                                        // Query to get both additions and usage
                                        String query = "";
                                        
                                        // Build query based on operation filter
                                        if("Used".equals(operation_filter)) {
                                            // Only show Used items
                                            query = "SELECT " +
                                                "ic.item_name, " +
                                                "'Used' as operation, " +
                                                "iu.quantity_used as quantity, " +
                                                "iu.category, " +
                                                "iu.date_used as transaction_date " +
                                            "FROM inventory_usage iu " +
                                            "LEFT JOIN inventory_core ic ON iu.inv_id = ic.inv_id " +
                                            "WHERE true " + xfilter_used + " " +
                                            "ORDER BY transaction_date DESC";
                                        } else if("Added".equals(operation_filter)) {
                                            // Only show Added items
                                            query = "SELECT " +
                                                "ic.item_name, " +
                                                "'Added' as operation, " +
                                                "ic.quantity as quantity, " +
                                                "ic.category, " +
                                                "ic.date_added as transaction_date " +
                                            "FROM inventory_core ic " +
                                            "WHERE true " + xfilter_added + " " +
                                            "ORDER BY transaction_date DESC";
                                        } else {
                                            // Show all (Added and Used)
                                            query = "SELECT " +
                                                "ic.item_name, " +
                                                "'Added' as operation, " +
                                                "ic.quantity as quantity, " +
                                                "ic.category, " +
                                                "ic.date_added as transaction_date " +
                                            "FROM inventory_core ic " +
                                            "WHERE true " + xfilter_added + " " +
                                            
                                            "UNION ALL " +
                                            
                                            "SELECT " +
                                                "ic.item_name, " +
                                                "'Used' as operation, " +
                                                "iu.quantity_used as quantity, " +
                                                "iu.category, " +
                                                "iu.date_used as transaction_date " +
                                            "FROM inventory_usage iu " +
                                            "LEFT JOIN inventory_core ic ON iu.inv_id = ic.inv_id " +
                                            "WHERE true " + xfilter_used + " " +
                                            
                                            "ORDER BY transaction_date DESC";
                                        }

                                        st = con.createStatement();
                                        rs = st.executeQuery(query);
                                        
                                        while(rs.next())
                                        {
                                            String item_name = rs.getString("item_name");
                                            String operation = rs.getString("operation");
                                            int quantity = rs.getInt("quantity");
                                            String category = rs.getString("category");
                                            String transaction_date = rs.getString("transaction_date");

                                            // Format date
                                            if (transaction_date != null && !"".equals(transaction_date)) {
                                                java.text.SimpleDateFormat fromDB = new java.text.SimpleDateFormat("yyyy-MM-dd");
                                                java.text.SimpleDateFormat toDisplay = new java.text.SimpleDateFormat("MM/dd/yyyy");
                                                java.util.Date parsed = fromDB.parse(transaction_date);
                                                transaction_date = toDisplay.format(parsed);
                                            } else {
                                                transaction_date = "N/A";
                                            }
                                    %>
                                    <tr>
                                        <td><%=item_name%></td>
                                        <td>
                                            <% if("Added".equals(operation)) { %>
                                                <span class="badge bg-success"><%=operation%></span>
                                            <% } else { %>
                                                <span class="badge bg-danger"><%=operation%></span>
                                            <% } %>
                                        </td>
                                        <td><%=quantity%></td>
                                        <td><%=category%></td>
                                        <td><%=transaction_date%></td>
                                    </tr>
                                    <%
                                        }
                                        con.close();
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
