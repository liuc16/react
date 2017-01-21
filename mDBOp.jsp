<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/youngtop/includes/jspHeader.jsp"%>

<%@page import="youngtop.sys.util.SecurityProxy"%>
<%@page import="youngtop.sys.util.DicConstants"%>
<%@page import="youngtop.dbop.tblbean.mdbop.YS_MDBOPRES"%>
<%@page import="youngtop.web.dbop.output.mdbop.MDBOpOutput"%>
<%@page import="youngtop.web.dbop.output.mdbop.MDBOpTopMenu"%>
<%@page import="youngtop.web.dbop.data.MDBOpInfo"%>
<%@page import="youngtop.web.dbop.WebDBOpKeys"%>
<%@page import="youngtop.web.sys.URLResUtil"%>
<%@ page import="youngtop.web.report.WebRepKeys"%>


<%@include file="/youngtop/includes/checkUserForward.jsp"%>

<%
 AppSession appSession=JspUtil.createAppSession(request);
 String strModid = RequestUtil.getParamValue(request, WebRepKeys.REP_MODID_KEY);
 MDBOpOutput mDBOpOutput=new MDBOpOutput(request,appSession);
 mDBOpOutput.init();
 MDBOpInfo mDBOpInfo=mDBOpOutput.getMDBOpInfo();
 YS_MDBOPRES mDBOpRes=mDBOpInfo.getMDBOpRes();
 SecurityProxy proxy=new SecurityProxy(appSession);
 if(proxy.hasMDBOpPermission(appSession.getCurUserID(),mDBOpRes)==false)
   throw new YoungtopException(YoungtopException.CLIENT_INFO,"您没有权限访问该资源(对应权限"+
              mDBOpRes.SUBSYS+"."+mDBOpRes.PERMISSIONID+")，请与系统管理员联系。");
 String mDBOpTags=mDBOpOutput.output();
 String subSys=mDBOpRes.SUBSYS;
 String mDBOpID=mDBOpRes.MDBOPID;
 String contextRoot=JspUtil.getContextRoot();
 String isFirstStr=RequestUtil.getParamValue(request,WebDBOpKeys.IS_FIRST_KEY);
 String isReturn=RequestUtil.getParamValue(request,WebDBOpKeys.MDBOP_ISRETURN_KEY);
 boolean isFirst=isFirstStr==null || isFirstStr.equals("1")?true:false;
 String tempStr=RequestUtil.getParamValue(request,WebKeys.ISTOPBAR_KEY);
 boolean isTopBar=tempStr!=null && tempStr.equals("0")?false:true;
 String curPageURL=null;
 if(!isFirst)
 {
   curPageURL=RequestUtil.getParamValue(request,WebKeys.CUR_PAGE_URL_KEY);//这样处理为是不将更新的数据全传到下继页面。
 }
 else
 {
   String[] exceptPrefixArr=new String[2];
   exceptPrefixArr[0]=WebKeys.ACTION_MESSAGE_KEY;
   exceptPrefixArr[1]="javax.servlet.forward";//tomcat中有
   String queryString=RequestUtil.getMyQueryString(request,exceptPrefixArr);
   curPageURL=contextRoot+"/sysmng.initMDBOp.do"+(queryString.equals("")?"":"?")+queryString;
 }
 String backActURL=RequestUtil.getParamValue(request,WebKeys.BACK_ACT_URL_KEY);
 if(backActURL==null)
   backActURL=RequestUtil.getParamValue(request,WebKeys.CALLER_PAGE_URL_KEY);
 String title=RequestUtil.getParamValue(request,WebDBOpKeys.MDBOP_TITLE_KEY);
 if(title==null || title.equals(""))
   title=mDBOpRes.RESDESC;
 String linkFormTarget=RequestUtil.getParamValue(request,WebKeys.LINK_FORM_TARGET_KEY);

 String isDesigner=RequestUtil.getParamValue(request,"isDesigner");
 String resouceid=RequestUtil.getParamValue(request,"resouceid");

 String formAction=mDBOpRes.FORMACTION;
 if(formAction==null || formAction.length()==0)
   formAction="sysmng.mDBOp.do";
 boolean isBackAct=backActURL!=null&&!backActURL.equals("") && (linkFormTarget==null || linkFormTarget.equals("")
               || linkFormTarget.equalsIgnoreCase("_self"));
 String toolBarTags=mDBOpOutput.createMDBOpToolBar(isBackAct).output();
 String funcMenuTags=mDBOpOutput.createMDBOpFuncMenu(isBackAct).output();
 String onloadEvent=mDBOpInfo.getOnLoadEvent();
 if(onloadEvent!=null && onloadEvent.length()>0)
   onloadEvent+=";";
 else
   onloadEvent="";
 MDBOpTopMenu topMenu=mDBOpOutput.createMDBOpTopMenu(isBackAct);
%>

<html>
<head>
  <%@include file="/youngtop/includes/htmlHeader1.jsp"%>
  <title><%=JspUtil.htmlFilter(title)%></title>
  <script language="javascript" src="<%=contextRoot%>/youngtop/jscript/mDBOp.js"></script>
  <script language="javascript" src="<%=contextRoot%>/youngtop/jscript/editForm.js"></script>
  <script language="javascript" src="<%=contextRoot%>/youngtop/jscript/report.js"></script>
  <script language="javascript" src="<%=contextRoot%>/youngtop/jscript/batchIns.js"></script>
  <link href="<%=contextRoot%>/youngtop/css/default/editForm.css" rel="stylesheet" type="text/css" />
  <link href="<%=contextRoot%>/youngtop/css/default/report.css" rel="stylesheet" type="text/css" />
  <%=URLResUtil.getCssJsExp(subSys,appSession)%>
  <%
  out.println(mDBOpOutput.getJsCssContent());
  %>
    <script type="text/javascript">
        $(function () {
            var obj = $('#formContainer');
            var innerObj = $(obj.find("table")[0]);
            obj.niceScroll({
                touchbehavior:false,
                cursorcolor:"#A1BBBA",
                cursoropacitymax:1,
                cursorwidth:5,
                cursorborder:"none",
                cursorborderradius:"4px",
                background:"#DFE8F6",
                zindex:998,
                autohidemode:false
            });

            innerObj.resize(function () {
                var maxRepHeight = $(document.body).height() - ($('#formContainer')[0].getBoundingClientRect().top - document.documentElement.clientTop) - $("#formBottomBar").height();

                if (innerObj.height() > maxRepHeight) {
                    $('#formContainer').css({height: maxRepHeight});
                } else {
                    $('#formContainer').css({height: innerObj.height()});
                }
            });

            PubUtil.topMenuResponsive("#topTools1");
            PubUtil.topMenuResponsive(".formtoolbar");
            PubUtil.topMenuResponsive(".formfunmenu");
        });
    </script>
</head>
<body style="height:100%;overflow: hidden;" onload="javascript:AppUtil.restoreDynaTags('dbOpContainer');AppUtil.initBatchInsTable();showMsg();<%=onloadEvent%>;PubUtil.reBodySize('dbOpContainer');PubUtil.topMenuAutoResponsive('#topTools1')">
<input type="hidden" id="hasShownMsg" value="0" />
<input type="hidden" id="cacheDynaTags" value="" />
<jsp:include page="/youngtop/includes/loadingMsg.jsp" />
<form name="mDBOpForm" action="<%=formAction%>" method="post" <%=mDBOpRes.FORMTYPE.intValue()==DicConstants.FORM_TYPE_UPLOAD?"enctype=\"multipart/form-data\"":""%> onkeydown="javascript:AppUtil.enterKeyDown(event);">
  <input type="hidden" name="<%=WebDBOpKeys.SUBSYS_KEY%>" value="<%=JspUtil.htmlFilter(subSys,false)%>" />
  <input type="hidden" name="<%=WebDBOpKeys.MDBOPID_KEY%>" value="<%=JspUtil.htmlFilter(mDBOpID,false)%>" />
  <input type="hidden" name="<%=WebDBOpKeys.IS_FIRST_KEY%>" value="0" />
  <input type="hidden" name="<%=WebDBOpKeys.MDBOP_TITLE_KEY%>" value="<%=JspUtil.htmlFilter(title,false)%>" />
  <input type="hidden" name="<%=WebKeys.CUR_PAGE_URL_KEY%>" value="<%=JspUtil.htmlFilter(curPageURL,false)%>" />
  <input type="hidden" name="<%=WebRepKeys.REP_MODID_KEY%>" value="<%=strModid%>"/>
  <input type="hidden" name="isDesigner" value="<%=isDesigner%>"/>
  <input type="hidden" name="resouceid" value="<%=resouceid%>"/>
  <%
  if(isReturn!=null)
  {%>
    <input type="hidden" name="<%=WebDBOpKeys.MDBOP_ISRETURN_KEY%>" value="<%=isReturn%>" />
  <%
  }
  String[] initParamNames=mDBOpInfo.getInitParamNames();
  for(int i=0;i<initParamNames.length;i++)
  {
	  String paramName=initParamNames[i];
	  String paramValue=RequestUtil.getParamValue(request,paramName);
%>
  <input type="hidden" name="<%=paramName%>" value="<%=JspUtil.htmlFilter(paramValue,false)%>" />
<%}
  if(backActURL!=null)
  {
  %>
  <input type="hidden" name="<%=WebKeys.BACK_ACT_URL_KEY%>" value="<%=JspUtil.htmlFilter(backActURL,false)%>" />
  <%
  }
  if(!isTopBar)
  {
  %>
  <input type="hidden" name="<%=WebKeys.ISTOPBAR_KEY%>" value="0" />
<%
  }
 %>
<%@include file="/youngtop/includes/userParams.jsp"%>
<div class="mdbopContainer">

            <%
            if(isTopBar)
            {%>
            <div id="topTools1">
                <%=topMenu.output() %>
            </div>
            <%}%>

            <div id="formContainer" style="overflow:hidden;">
                <%=mDBOpTags%><%--DB组合操作标签--%></div>
            <div id="formBottomBar">
            <%=toolBarTags%>
            <%=funcMenuTags%>
            </div>
</div>
</form>
<form name="linkForm" class="form-horizontal"  method="post" action="">
  <input type="hidden" name="<%=WebKeys.CALLER_PAGE_URL_KEY%>" value="<%=JspUtil.htmlFilter(curPageURL,false)%>" />
</form>
<form name="backForm" method="post" action=""><!--用到返回至调用页面-->
</form>
</body>
</html>


