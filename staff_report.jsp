<%@page import="java.sql.*" %>
<%@page import="java.text.SimpleDateFormat" %>
<%@page import="java.util.*" %>

<% 
    String action = request.getParameter("action");
    String year_filter = "";
    String month_filter = "";
    String status_filter = "";
    String date_start_filter = "";
    String date_end_filter = "";
    
    // Get current year and month as defaults
    Calendar cal = Calendar.getInstance();
    int currentYear = cal.get(Calendar.YEAR);
    int currentMonth = cal.get(Calendar.MONTH) + 1; // Calendar.MONTH is 0-based
    
    String xfilter = "";

    if("search".equals(action)){
        year_filter = request.getParameter("year_filter");
        month_filter = request.getParameter("month_filter");
        status_filter = request.getParameter("status_filter");
        date_start_filter = request.getParameter("date_start_filter");
        date_end_filter = request.getParameter("date_end_filter");

        // Year/month filters (optional)
        if(year_filter != null && !year_filter.isEmpty() && !"All".equals(year_filter)){
            xfilter += " AND YEAR(latest_dri.date_recorded) = " + year_filter;
        }

        if(month_filter != null && !month_filter.isEmpty() && !"All".equals(month_filter)){
            xfilter += " AND MONTH(latest_dri.date_recorded) = " + month_filter;
        }

        // Status filter: Available means either latest repair is Repaired OR no damage record exists
        if(status_filter != null && !status_filter.isEmpty() && !"All".equals(status_filter)){
            if("Available".equals(status_filter)){
                xfilter += " AND (dr.status = 'Repaired' OR latest_dri.dri_id IS NULL)";
            } else if("Not Available".equals(status_filter)){
                xfilter += " AND (latest_dri.dri_id IS NOT NULL AND (dr.status IS NULL OR dr.status != 'Repaired'))";
            }
        }

        // Date range filters (based on damage_recording_infra.date_recorded)
        if(date_start_filter != null && !date_start_filter.isEmpty()){
            xfilter += " AND latest_dri.date_recorded >= '" + date_start_filter + "'";
        }

        if(date_end_filter != null && !date_end_filter.isEmpty()){
            xfilter += " AND latest_dri.date_recorded <= '" + date_end_filter + "'";
        }
    } else {
        // no search: do not filter by date or availability by default
        year_filter = String.valueOf(currentYear);
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
                margin-bottom: 17px;
            }
            .summary-card {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                border-radius: 10px;
                padding: 20px;
                color: white;
                margin-bottom: 20px;
            }
            .summary-number {
                font-size: 48px;
                font-weight: bold;
            }
            .summary-label {
                font-size: 18px;
                opacity: 0.9;
            }
        </style>
        <script src="bootstrap-5.2.3-dist/js/bootstrap.bundle.js"></script>
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
                            <div class="d-flex" style="width:90%;margin-top:40px">
                                <div style="font-family:arial;font-size:28px;font-family:arial;display:flex;flex-direction:row">
                                    Staff Activity Report
                                </div>

                                <button class="btn btn-primary fw-bold" style="margin-left:auto" type="submit" name="action" value="search">
                                    Search
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-search" viewBox="0 0 16 16">
                                        <path d="M11.742 10.344a6.5 6.5 0 1 0-1.397 1.398h-.001q.044.06.098.115l3.85 3.85a1 1 0 0 0 1.415-1.414l-3.85-3.85a1 1 0 0 0-.115-.1zM12 6.5a5.5 5.5 0 1 1-11 0 5.5 5.5 0 0 1 11 0"/>
                                    </svg>
                                </button>
                            </div>
                    
                            <div style="display:flex;flex-direction:row;justify-content:flex-start;width:90%;margin-top:20px">
                                <div style="display:flex;flex-direction:row;align-items:center">
                                    <div style="font-size:24px">
                                        Year: 
                                    </div>
                                    <select class="form-select" style="margin-left:15px;width:150px" name="year_filter" id="year_filter">
                                        <option value="All" <%= "All".equals(year_filter) ? "selected" : "" %>>All Years</option>
                                        <%
                                            for(int y = currentYear; y >= currentYear - 5; y--) {
                                        %>
                                        <option value="<%=y%>" <%= String.valueOf(y).equals(year_filter) ? "selected" : "" %>><%=y%></option>
                                        <%
                                            }
                                        %>
                                    </select>

                                    <div style="font-size:24px;margin-left:20px">
                                        Month:
                                    </div>
                                    <select class="form-select" style="margin-left:15px;width:150px" name="month_filter" id="month_filter">
                                        <option value="All" <%= "All".equals(month_filter) ? "selected" : "" %>>All Months</option>
                                        <option value="1" <%= "1".equals(month_filter) ? "selected" : "" %>>January</option>
                                        <option value="2" <%= "2".equals(month_filter) ? "selected" : "" %>>February</option>
                                        <option value="3" <%= "3".equals(month_filter) ? "selected" : "" %>>March</option>
                                        <option value="4" <%= "4".equals(month_filter) ? "selected" : "" %>>April</option>
                                        <option value="5" <%= "5".equals(month_filter) ? "selected" : "" %>>May</option>
                                        <option value="6" <%= "6".equals(month_filter) ? "selected" : "" %>>June</option>
                                        <option value="7" <%= "7".equals(month_filter) ? "selected" : "" %>>July</option>
                                        <option value="8" <%= "8".equals(month_filter) ? "selected" : "" %>>August</option>
                                        <option value="9" <%= "9".equals(month_filter) ? "selected" : "" %>>September</option>
                                        <option value="10" <%= "10".equals(month_filter) ? "selected" : "" %>>October</option>
                                        <option value="11" <%= "11".equals(month_filter) ? "selected" : "" %>>November</option>
                                        <option value="12" <%= "12".equals(month_filter) ? "selected" : "" %>>December</option>
                                    </select>
                                    
                                    <div style="font-size:24px;margin-left:20px">
                                        Status:
                                    </div>
                                    <select class="form-select" style="margin-left:15px;width:180px" name="status_filter" id="status_filter">
                                        <option value="All" <%= "All".equals(status_filter) ? "selected" : "" %>>All</option>
                                        <option value="Available" <%= "Available".equals(status_filter) ? "selected" : "" %>>Available</option>
                                        <option value="Not Available" <%= "Not Available".equals(status_filter) ? "selected" : "" %>>Not Available</option>
                                    </select>
                                </div>
                            </div>

                            <%
                                // Summary statistics
                                Connection conSummary = null;
                                Statement stSummary = null;
                                ResultSet rsSummary = null;
                                int totalStaffAssigned = 0;
                                int activeRepairs = 0;
                                int completedRepairs = 0;

                                try {
                                    Class.forName("com.mysql.jdbc.Driver");
                                    conSummary = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
                                    stSummary = conSummary.createStatement();
                                    
                                    // Count total staff assigned
                                    String summaryQuery = "SELECT COUNT(DISTINCT dri.stf_id) as total_staff, " +
                                                         "SUM(CASE WHEN dr.status IN ('For Repair', 'Repairing') THEN 1 ELSE 0 END) as active_repairs, " +
                                                         "SUM(CASE WHEN dr.status = 'Repaired' THEN 1 ELSE 0 END) as completed_repairs " +
                                                         "FROM damage_recording_infra dri " +
                                                         "LEFT JOIN damage_repair dr ON dri.dri_id = dr.dri_id " +
                                                         "WHERE dri.stf_id IS NOT NULL " + xfilter;
                                    
                                    rsSummary = stSummary.executeQuery(summaryQuery);
                                    if(rsSummary.next()) {
                                        totalStaffAssigned = rsSummary.getInt("total_staff");
                                        activeRepairs = rsSummary.getInt("active_repairs");
                                        completedRepairs = rsSummary.getInt("completed_repairs");
                                    }
                                } catch(Exception e) {
                                    e.printStackTrace();
                                } finally {
                                    if(rsSummary != null) try { rsSummary.close(); } catch(Exception e) {}
                                    if(stSummary != null) try { stSummary.close(); } catch(Exception e) {}
                                    if(conSummary != null) try { conSummary.close(); } catch(Exception e) {}
                                }
                            %>

                            <!-- Summary Cards -->
                            <div class="row" style="width:90%;margin-top:20px">
                                <div class="col-md-4">
                                    <div class="summary-card">
                                        <div class="summary-number"><%=totalStaffAssigned%></div>
                                        <div class="summary-label">Staff Assigned</div>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="summary-card" style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);">
                                        <div class="summary-number"><%=activeRepairs%></div>
                                        <div class="summary-label">Active Repairs</div>
                                    </div>
                                </div> 
                                <div class="col-md-4">
                                    <div class="summary-card" style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);">
                                        <div class="summary-number"><%=completedRepairs%></div>
                                        <div class="summary-label">Completed Repairs</div>
                                    </div>
                                </div>
                            </div>

                            <div style="width:100%;display:flex;justify-content:center;margin-top:20px;overflow-y:auto;max-height:calc(100vh - 400px)">
                                <table class="table table-striped" style="width:90%">
                                    <thead>
                                        <tr>
                                            <td class="fw-bold">Staff Name</td>
                                            <td class="fw-bold">Status</td>
                                            <td class="fw-bold">Infrastructure Location</td>
                                            <td class="fw-bold">Date Recorded</td>
                                            <td class="fw-bold">Repair Status</td>
                                            <td class="fw-bold">Date Started</td>
                                            <td class="fw-bold">Date Completed</td>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <%
                                            Connection con = null;
                                            Statement st = null;
                                            ResultSet rs = null;
                                        
                                            try {
                                                Class.forName("com.mysql.jdbc.Driver");
                                                con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","ccinfomgoat9");
                                        
                                                String query = "SELECT " +
                                                              "s.stf_id, " +
                                                              "CONCAT(s.staff_fname, ' ', COALESCE(s.staff_midname, ''), ' ', s.staff_lname) as staff_name, " +
                                                              "s.availability as db_availability, " +
                                                              "i.location as infrastructure_location, " +
                                                              "latest_dri.dri_id as latest_dri_id, " +
                                                              "latest_dri.date_recorded as date_recorded, " +
                                                              "dr.status as repair_status, " +
                                                              "dr.date_start, " +
                                                              "dr.date_end, " +
                                                              "latest_dri.damage_details " +
                                                              "FROM staff_core s " +
                                                              "LEFT JOIN ( " +
                                                              "  SELECT dri.stf_id, dri.dri_id, dri.inf_id, dri.date_recorded, dri.date_staff_assigned, dri.damage_details " +
                                                              "  FROM damage_recording_infra dri " +
                                                              "  WHERE dri.date_recorded = ( " +
                                                              "    SELECT MAX(dri2.date_recorded) " +
                                                              "    FROM damage_recording_infra dri2 " +
                                                              "    WHERE dri.stf_id = dri2.stf_id " +
                                                              "  ) " +
                                                              " ) latest_dri ON s.stf_id = latest_dri.stf_id " +
                                                              "LEFT JOIN infrastructure_core i ON latest_dri.inf_id = i.inf_id " +
                                                              "LEFT JOIN damage_repair dr ON latest_dri.dri_id = dr.dri_id " +
                                                              "WHERE true " + xfilter +
                                                              " ORDER BY latest_dri.date_recorded DESC, s.staff_lname ASC";

                                                st = con.createStatement();
                                                rs = st.executeQuery(query);
                                                
                                                SimpleDateFormat fromDB = new SimpleDateFormat("yyyy-MM-dd");
                                                SimpleDateFormat toDisplay = new SimpleDateFormat("MM/dd/yyyy");

                                                while(rs.next()) {
                                                    String staff_name = rs.getString("staff_name");
                                                    String db_availability = rs.getString("db_availability");
                                                    String infrastructure = rs.getString("infrastructure_location");
                                                    String latest_dri_id = rs.getString("latest_dri_id");
                                                    String date_recorded = rs.getString("date_recorded");
                                                    String repair_status = rs.getString("repair_status");
                                                    String date_start = rs.getString("date_start");
                                                    String date_end = rs.getString("date_end");
                                                    
                                                    // Format dates
                                                    if(date_recorded != null && !date_recorded.isEmpty()) {
                                                        try {
                                                            java.util.Date parsed = fromDB.parse(date_recorded);
                                                            date_recorded = toDisplay.format(parsed);
                                                        } catch(Exception e) {}
                                                    } else {
                                                        date_recorded = "N/A";
                                                    }
                                                    
                                                    if(date_start != null && !date_start.isEmpty()) {
                                                        try {
                                                            java.util.Date parsed = fromDB.parse(date_start);
                                                            date_start = toDisplay.format(parsed);
                                                        } catch(Exception e) {}
                                                    } else {
                                                        date_start = "N/A";
                                                    }
                                                    
                                                    if(date_end != null && !date_end.isEmpty()) {
                                                        try {
                                                            java.util.Date parsed = fromDB.parse(date_end);
                                                            date_end = toDisplay.format(parsed);
                                                        } catch(Exception e) {}
                                                    } else {
                                                        date_end = "N/A";
                                                    }
                                                    
                                                    if(repair_status == null) repair_status = "Not Started";
                                                    if(infrastructure == null) infrastructure = "N/A";
                                                    // Compute availability: Available if no latest_dri OR latest repair status is Repaired
                                                    String availability;
                                                    if(latest_dri_id == null || latest_dri_id.isEmpty()) {
                                                        availability = "Available"; // scenario 2: no record found
                                                    } else if("Repaired".equals(repair_status)) {
                                                        availability = "Available"; // scenario 1: repaired
                                                    } else {
                                                        availability = "Not available";
                                                    }
                                                    
                                                    // Status badge color
                                                    String statusClass = "";
                                                    if("Repaired".equals(repair_status)) {
                                                        statusClass = "badge bg-success";
                                                    } else if("Repairing".equals(repair_status)) {
                                                        statusClass = "badge bg-warning text-dark";
                                                    } else if("For Repair".equals(repair_status)) {
                                                        statusClass = "badge bg-info text-dark";
                                                    } else if("Not Started".equals(repair_status)) {
                                                        statusClass = "badge bg-danger";
                                                    } else {
                                                        statusClass = "badge bg-secondary";
                                                    }
                                        %>
                                        <tr>
                                            <td><%=staff_name%></td>
                                            <td><%=availability%></td>
                                            <td><%=infrastructure%></td>
                                            <td><%=date_recorded%></td>
                                            <td><span class="<%=statusClass%>"><%=repair_status%></span></td>
                                            <td><%=date_start%></td>
                                            <td><%=date_end%></td>
                                        </tr>
                                        <%
                                                }
                                                
                                                if(!rs.isBeforeFirst()) {
                                        %>
                                        <tr>
                                            <td colspan="7" class="text-center text-muted">
                                            </td>
                                        </tr>
                                        <%
                                                }
                                            } catch(Exception e) {
                                        %>
                                        <tr>
                                            <td colspan="7" class="text-center text-danger">
                                                <strong>Error loading records:</strong> <%= e.getMessage() %>
                                            </td>
                                        </tr>
                                        <%
                                                e.printStackTrace();
                                            } finally {
                                                if(rs != null) try { rs.close(); } catch(Exception e) {}
                                                if(st != null) try { st.close(); } catch(Exception e) {}
                                                if(con != null) try { con.close(); } catch(Exception e) {}
                                            }
                                        %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </form>
                </td>
            </tr>
        </table>
    </body>
</html>