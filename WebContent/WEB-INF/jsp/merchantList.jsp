<%@ taglib prefix = "c" uri = "http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt"  uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<link rel="stylesheet" href="/dino/html/css/style.css?16">
<!DOCTYPE html>
<html>
<head>
<title>Merchant List</title>
<script language="javascript">
  	function showPopup() {
  	  	window.open("/dino/html/detail.html", 
  	  				"Merchant Detail", 
  	  				"toolbar=no, location=no, directories=no, status=no, menubar=no, scrollbars=no, resizable=no, copyhistory=no width=400, height=300"); 
	}
</script>
</head>
<body>
<div >
<table>
	<thead>
	<tr>
		<th colspan="2">상점</th>
		<th>주소</th>
		<th>오픈일</th>
		<th>공룡수</th>
		<th>유저수</th>
	</tr>
	</thead>
	<c:forEach var="listValue" items="${list}">
	<tbody>
	<tr>
		<td align="right">
        	<img src="/dino/html/images/${listValue.mctIcon}" onclick="showPopup();" > 
        </td> 
	  	<td align="left">
        	<c:out value="${listValue.mctName}"/>
        </td>  
	   	<td>
        	<c:out value="${listValue.mctAddr}"/>
        </td> 
	   	<td><fmt:formatDate value="${listValue.createDate}" pattern="yyyy.MM.dd" /></td> 
	  	<td><c:out value="${listValue.monsterCount}"/></td> 
	  	<td><c:out value="${listValue.userCount}" /> </td> 
	</tr>
	</tbody>
	</c:forEach>
</table>
</div>

</body>
</html>