    
    <%@page import="java.sql.*" %>

    <% 
        //if(request.getParameter("submit"))

        //Connection con;
        //PreparedStatment pat;
        //ResultSet rs; 

        //Class.forName("com.mysql.jdbc.Driver");
        //con = DriverManager.getConnection("jdbc:mysql://localhost/ccinfom_project","root","p@assw0rd");
        //pat = con.prepareStatement("")
        
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
            <link rel="stylesheet" href="bootstrap-5.2.3-dist/css/bootstrap.css">
        </head>

        <body style="overflow:hidden">

            <h1>MySQL Connection Diagnostic</h1>
    
            <h2>Test 1: Empty Password</h2>
            <%
                try {
                    Class.forName("com.mysql.jdbc.Driver");
                    Connection con = DriverManager.getConnection(
                        "jdbc:mysql://localhost:3307/ccinfom_project",
                        "root",
                        ""  // No password
                    );
                    out.println("<p style='color:green;'>✓ SUCCESS with EMPTY password!</p>");
                    con.close();
                } catch(Exception e) {
                    out.println("<p style='color:red;'>✗ Failed: " + e.getMessage() + "</p>");
                }
            %>
            
            <h2>Test 2: Password = root</h2>
            <%
                try {
                    Class.forName("com.mysql.jdbc.Driver");
                    Connection con = DriverManager.getConnection(
                        "jdbc:mysql://localhost:3307/ccinfom_project",
                        "root",
                        "root"
                    );
                    out.println("<p style='color:green;'>✓ SUCCESS with password 'root'!</p>");
                    con.close();
                } catch(Exception e) {
                    out.println("<p style='color:red;'>✗ Failed: " + e.getMessage() + "</p>");
                }
            %>
            
            <h2>Test 3: Password = p@assw0rd</h2>
            <%
                try {
                    Class.forName("com.mysql.jdbc.Driver");
                    Connection con = DriverManager.getConnection(
                        "jdbc:mysql://localhost:3307/ccinfom_project",
                        "root",
                        "p@assw0rd"
                    );
                    out.println("<p style='color:green;'>✓ SUCCESS with password 'p@assw0rd'!</p>");
                    con.close();
                } catch(Exception e) {
                    out.println("<p style='color:red;'>✗ Failed: " + e.getMessage() + "</p>");
                }
            %>
        
            <h2>Test 4: Port 3306 (default MySQL)</h2>
            <%
                try {
                    Class.forName("com.mysql.jdbc.Driver");
                    Connection con = DriverManager.getConnection(
                        "jdbc:mysql://localhost:3306/ccinfom_project",
                        "root",
                        "p@ssword"
                    );
                    out.println("<p style='color:green;'>✓ SUCCESS on port 3306!</p>");
                    con.close();
                } catch(Exception e) {
                    out.println("<p style='color:red;'>✗ Failed: " + e.getMessage() + "</p>");
                }
            %>


            <table style="overflow:none">

                <tr>
                    <td>
                        <jsp:include page="/sidebar.jsp" />
                    </td>

                    <td style="width:calc(100vw - 350px)" class="d-flex align-items-center">

                        <form  method="POST" action="#" style="width:100%;height:100%">

                            <div style="width:100%;display:flex;justify-content:center;flex-direction:column">
                                <div class="d-flex" style="width:80%;margin-top:20px">
                                    <div style="font-family:arial;font-size:25px">
                                        Infrastructure Record
                                    </div>

                                    <button class="btn btn-primary" style="margin-left:auto">
                                        Add Record
                                    </button>
                                </div>

                                <div style="width:100%;display:flex;justify-content:center">
                                    <table class="table table-striped" style="width:80%">

                                        <thead>
                                            <tr>
                                                <td>
                                                    Location
                                                </td>
    
                                                <td>
                                                    Type of Location
                                                </td>
    
                                                <td>
                                                    Status
                                                </td>
    
                                                <td>
                                                    Action
                                                </td>
                                            </tr>
                                        </thead>


                                        <%
                                            Connection con;
                                            PreparedStatement pat;
                                            ResultSet rs; 
                                    
                                            Class.forName("com.mysql.jdbc.Driver");
                                            con = DriverManager.getConnection("jdbc:mysql://localhost:3307/ccinfom_project","root","p@assword");

                                            String query = "select * FROM infrastructure_core";
                                            Statement st = con.createStatement();
                                            rs = st.executeQuery(query);

                                            while(rs.next())
                                            {
                                                String status = rs.getString("status");
                                                String type_of_infra = rs.getString("type_of_infra");
                                                String location = rs.getString("location");
                                            


                                        %>
                                        <tr>
                                            <td><%=rs.getString("location")%></td>
                                            <td><%=rs.getString("type_of_infra")%></td>
                                            <td><%=rs.getString("status")%></td>
                                            <td>
                                                <div class="dropdown">
                                                <button class="btn btn-secondary dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                                                  Dropdown button
                                                </button>
                                                <ul class="dropdown-menu">
                                                  <li><a class="dropdown-item" href="#">Action</a></li>
                                                  <li><a class="dropdown-item" href="#">Another action</a></li>
                                                  <li><a class="dropdown-item" href="#">Something else here</a></li>
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

                    </td>
                </tr>

            </table>

        </body>

    </html>