/// <pre>
/// Copyright (c) Alex Woodhead 2020
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
/// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
/// 
/// License MIT
/// Source: https://github.com/alexatwoodhead/ompare
/// Version: 1.0
/// </pre>
Class ompare.Report.Main Extends %CSP.Page
{

ClassMethod ArrayToList(ByRef ary) As %List
{
 set ret=$LB()
 set env="",ecount=0
 for {
	set env=$O(ary(env))
	quit:env=""
	set ecount=ecount+1
	set elist=$LB(env)
	
	set nslist=$LB()
	set nscount=0
	set ns=""
	for {
		set ns=$O(ary(env,ns))
		quit:ns=""
		set nscount=nscount+1
		set $LIST(nslist,nscount)=ns
	}
	if $LL(nslist)>1 {
		set $LIST(elist,2)=nslist
		set $LIST(ret,ecount)=elist
	}
 } 
 quit ret
}

ClassMethod ListToArray(list As %List = {$LB()}, Output ary)
{
	kill ary
	Quit:'$LV(list)
	set elen=$LL(list)
	for i=1:1:elen {
		set envlist=$LG(list,i,"")	
		continue:'$LV(envlist)
		continue:$LL(envlist)<2
		set env=$LG(envlist,1,"")
		continue:env=""
		set nslist=$LG(envlist,2,"")
		continue:'$LV(nslist)
		set nslen=$LL(nslist)
		continue:nslen<1
		
		for j=1:1:nslen {
			set ns=$LG(nslist,j,"")
			continue:ns=""
			set ary(env,ns)=""
		}
	}
}

ClassMethod Header(action = "")
{
	W !,"<script>"
	W !,"function doAction(action,report,p1,p2,p3,p4) {"
	W !,"  var frm=document.getElementById('frmCommon');"
	W !,"  if (frm==null) { "
	//W !,"    alert('frm is null');"
	W !,"    return;"
	W !,"  }"
	W !,"  frm.elements['Action'].value=action;"
	W !,"  if ((typeof(report)!='undefined')&&(report!=null)) frm.elements['report'].value=report;"
	W !,"  if ((typeof(p1)!='undefined')&&(p1!=null)) frm.elements['P1'].value=p1;"
	W !,"  if ((typeof(p2)!='undefined')&&(p2!=null)) frm.elements['P2'].value=p2;"
	W !,"  if ((typeof(p3)!='undefined')&&(p3!=null)) frm.elements['P3'].value=p3;"
	W !,"  if ((typeof(p4)!='undefined')&&(p4!=null)) frm.elements['P4'].value=p4;"
	W !,"  //setFieldValue('frmCommon_Action',action);"
	W !,"  //setFieldValue('frmCommon_P1',p1);"
	// Client Alert message box to show what values are passed back for Menu actions
	//W !,"  alert('action='+action+'\nreport='+report+'\np1='+p1+'\np2'+p2+'\np3'+p3+'\p4'+p4);"
	
	W !,"  frm.submit();"
	W !,"}"
	W !,"</script>"
	W !,"<form id=""frmCommon"" name=""frmCommon"">"
	W !,"<input type=""hidden"" name=""Action"" value=""""/>"
	W !,"<input type=""hidden"" name=""report"" value=""""/>"
	W !,"<input type=""hidden"" name=""P1"" value=""""/>"
	W !,"<input type=""hidden"" name=""P2"" value=""""/>"
	W !,"<input type=""hidden"" name=""P3"" value=""""/>"
	W !,"<input type=""hidden"" name=""P4"" value=""""/>"
	W !,"</form>"
	
	if action'="Dynamic" {
		W !,"<button onclick=""doAction('Dynamic')"">Dynamic</button>"
	} else {
		W !,"<button disabled=1>Dynamic</button>"
	}
	if action'="New",action'="Edit" {
		W !,"<button onclick=""doAction('New')"">New Report</button>"
	} else {
		W !,"<button disabled=1>New Report</button>"
	}
	if action'="List" {
		W !,"<button onclick=""doAction('List')"">List Reports</button>"
	} else {
		W !,"<button disabled=1>List Reports</button>"	
	}
	if action'="NewXLS",action'="EditXLS" {
		W !,"<button onclick=""doAction('NewXLS')"">New Excel Workbook</button>"
	} else {
		W !,"<button disabled=1>New Excel Workbook</button>"
	}
	if action'="ListXLS" {
		W !,"<button onclick=""doAction('ListXLS')"">List Excel Workbooks</button>"
	} else {
		W !,"<button disabled=1>List Excel Workbooks</button>"
	}
	if action'="ImportSummary" {
		W !,"<button onclick=""doAction('ImportSummary')"">Import Summary</button>"	
	} else {
		W !,"<button disabled=1>Import Summary</button>"
	}
	
	W !,"<hr/>"
}

ClassMethod Footer()
{
}

/// Event handler for <b>PAGE</b> event: this is invoked in order to  
/// generate the content of a csp page.
ClassMethod OnPage() As %Status [ ServerOnly = 1 ]
{
	W !,"<html>"
	W !,"<head>"
	W !,"<style>"
	W !,".ListT {"
	W !,"  Width:100%;"
	W !,"  background-color:navy;"
	W !,"  border:0;"
	W !,"  cell-spacing:1;"
	W !,"  cell-padding:0"
	W !,"}"
	W !,".ListTn {"
	W !,"  background-color:navy;"
	W !,"  border:0;"
	W !,"  cell-spacing:1;"
	W !,"  cell-padding:0"
	W !,"}"
	W !,".ListTRH {"
	W !,"  background-color:#D3D3D3"
	W !,"}"
	W !,".ListTH1 {"
	W !,"  Width:10%;"
	W !,"  white-space:nowrap"
	W !,"}"
	W !,".ListTH1n {"
	W !,"  white-space:nowrap"
	W !,"}"
	W !,".ListTH2 {"
	W !,"  Width:10%"
	W !,"}"
	W !,".ListTH3 {"
	W !,"  Width:20%"
	W !,"}"
	W !,".ListTHE {"
	W !,"  Width:*;"
	W !,"  text-align:right"
	W !,"}"
	W !,".ListTRD {"
	W !,"  background-color:white"
	W !,"}"
	W !,".ListTD1 {"
	W !,"  Width:10%;"
	W !,"  white-space:nowrap;"
	W !,"  text-align:left"
	W !,"}"
	W !,".ListTD1n {"
	W !,"  white-space:nowrap;"
	W !,"  text-align:left"
	W !,"}"
	W !,".ListTD2 {"
	W !,"  Width:10%;"
	W !,"  text-align:center"
	W !,"}"
	W !,".ListTD2n {"
	W !,"  text-align:center"
	W !,"}"
	W !,".ListTDE {"
	W !,"  Width:*;"
	W !,"  text-align:right"
	W !,"}"
	W !,".btnDel {"
	W !,"  background-image:url(data:image/png:base64,iVBORw0KGgoAAAANSUhEUgAAACIAAAAaCAIAAABdDBlVAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAFFSURBVEhL7dRPS4NwHMfx3zPxcXgOegwDj7vYE7DzTnWIDU+xakE3EeviLjGCQYd17TBjh8LJKFr9dJt/8s/a+gaCprOc8L0FLxB/yueNF8mp3LsfGV64QgLjkCAHxzLczLwICYxDIs5YboQkybjBp+mESGA8yVA7QJLOLN8XPhIYTzLTuY8knYleZx9IYDzOOH70YnpIYDzJPFO3pLv2/m77MXP4iyRje+HkzSmrK+51c4fFYDzOLLzAmNp/U0WGFSVV5NVbnuV4NffCJjAeZ+ZuMNRpOf06yzFsq5M9LwTj22eUFiP0OwJXV3KPClTIaI2a0BjQ4UDaqUnX2aebVfqa7WUyJpL/TAU/MtrYRJLOhNrYQgLj35lD/AwkyNGJAn+3B8NCAuOQIOdyb/Q0Wa3XSGD84uqGaDqFS/PsEgmMazr9Ag06H2qCpXNxAAAAAElFTkSuQmCC);"
	W !,"  Height:15;"
	W !,"  Width:15;"
	W !,"}"
	W !,"</style>"
	W !,"</head>"
	W !,"<body>"
	W !,"<a name=""showTop""></a>"
	
	set action=$Get(%request.Data("Action",1),"List")
	set template=$G(%request.Data("Template",1),"")
	if action="List" {
		Do ..DisplayPageListReports()
	} elseif action="New" {
		Do ..DisplayPageEditOrNewReport()
	} elseif action="Edit" {
		Do ..DisplayPageEditOrNewReport()
	} elseif action="View" {
		Do ..DisplayPageViewReport()
	} elseif action="Config" {
		Do ..DisplayPageConfig()
	//} elseif action="Analyse" {
		//Do ..DisplayPageAnalyseLocal()
	} elseif action="NewXLS" {
		Do ..DisplayPageEditOrNewXLS()
	} elseif action="EditXLS" {
		Do ..DisplayPageEditOrNewXLS()
	} elseif action="ListXLS" {
		Do ..DisplayPageListXLS()
	//} elseif action="DLLS" {
		//Do ..DisplayPageEditDLLS()
	} elseif action="Dynamic" {
		Do ..DisplayPageDynamic()	
	} elseif action="ImportSummary" {
		Do ..DisplayImportSummary()
	} else {
		W !,"Action """,action,""" Not implemented"	
	}
	
	W !,"</body>"
	W !,"</html>"
	Quit $$$OK
}

ClassMethod DisplayImportSummary()
{
	Do ..Header("Import Summary")
	
	W !,"<p>Displays information on when and where the profile process for generating Source Compare signatures were run.</p>"
	
	W !,"<table class='ListT'>"	
	W !,"  <tr class='ListTRH'>"
	for i="Environment","Server","Instance","Date","Time" {
		W !,"    <th class='ListTH1'>",$ZCVT(i,"O","HTML"),"</th>"
	}
	W !,"  </tr>"
	
	
	set ccrSystem=""
	for {
		set ccrSystem=$Order(^ompare("Data",ccrSystem),+1,data)
		quit:ccrSystem=""
		W !,"  <tr class='ListTRD'>"
		//^ompare("Data","BASEINST") = "64917^72584^NHSW-LAB-BASE.iscinternal.com^ENSEMBLE" 
		set server=$ZCVT($P(data,"^",3),"O","HTML")
		set instance=$ZCVT($P(data,"^",4),"O","HTML")
		set date=+$P(data,"^",1)
		if date=0 {
			set date="Not stated"
		} else {
			set date=$ZD(date,3,,,,,,,"Error")
		}
		set time=+$P(data,"^",2)
		if time=0 {
			set time="Not stated"
		} else {
			set time=$ZT(time,,,"Error")
		}
		W !,"<td class='ListTD1'>",$ZCVT(ccrSystem,"O","HTML"),"</td>"
		W !,"<td class='ListTD1'>",server,"</td>"
		W !,"<td class='ListTD1'>",instance,"</td>"
		W !,"<td class='ListTD1'>",date,"</td>"
		W !,"<td class='ListTD1'>",time,"</td>"
		W !,"  </tr>"
	}
	
	W !,"</table>"
	do ..Footer()
}

/// DisplayForm
ClassMethod DisplayPageDynamic()
{
	Do ..Header("Dynamic")
	
	W !,"Enter name or class or routine to analyse"
	
	W !,"<form id=""frmData"" name=""frmData"" method=""POST"">"
	W !,"<input type=""hidden"" name=""Action"" value=""View""/>"
	W !,"<input type=""hidden"" name=""report"" value=""_Dynamic""/>"
	
	write !,"Select Type: <select name=""type"">"
	write !,"<option value="" "">[ Choose Option ]</option>"
	write !,"<option value=""cls"">Class</option>"
	write !,"<option value=""rou"">Routine</option>"
	write !,"</select>"
	W !,"<br/>Source Code Name: <input type=""text"" name=""sourcename"" size=""120""/>"
	W !,"<br/><input type=""submit"" value=""Analyse""/>"
	
	W !,"</form>"
	
	do ..Footer()
}

ClassMethod DisplayPageListReports()
{
	// Handle Delete Report scenario
	// before display list of available Reports.
	set report=$Get(%request.Data("report",1))
	set doDelete=$S($Get(%request.Data("P1",1))="Delete":1,1:0)
	
	if report'="",doDelete=1 {
		do ##class(ompare.Report.Definition).%DeleteId(report)
	}
	// End Handle Delete
	
	Do ..Header("List")

	// Display a "New" template button
	Do ##class(ompare.Report.Definition).ListReportByCategory(.categories,.reports)
	Set category=$G(%request.Data("P1",1),"_")
	if category="" {
		// No ListCategory chosen.
		// Default to a previous ListCategory choice if possible
		set:$Data(%session) category=$G(%session.Data("ListCategory"))
	} elseif category="_" {
		// Placeholder do nothing
		set category=""
	} else {
		// Remember the chosen List Category
		set %session.Data("ListCategory")=category
	}
	
	W !,"Filter on Report List Category: <select onchange=""doAction('List','',this.value)"">"
	W !,"<option value=""_""",$S(category="":" selected ",1:""),">[ No Filter ]</option>"
	set option=""
	for {
		set option=$O(categories(option))
		quit:option=""
		W !,"<option "
		if option=category W "selected "
		if option=" " {
			W "value="" "">[ Uncategorised ]"
		} else {
			W "value=""",$ZCONVERT(option,"O","HTML"),""">",$ZCONVERT(option,"O","HTML")
		}
		W "</option>"
	}
	W !,"</select>"
	
	// Display a list of existing Templates
	W !,"<table class='ListT'>"
	W !,"<tr class='ListTRH'>"
	W !,"<th class='ListTH1'>Report Name</th>"
	W !,"<th class='ListTH2'>Edit</th>"
	W !,"<th class='ListTH2'>View</th>"
	W !,"<th class='ListTHE'>Delete</th>"
	W !,"</tr>"
	set report=""
	for {
		set report=$Order(reports(report))
		quit:report=""
		// Category selected. Only show chosen category

		if category'="",category'=" ",'$Data(categories(category,report)) continue
		// Uncategorised selected. Only show uncategorised " "
		if category=" ",'$Data(categories(category,report)) continue
		// Otherwise show all reports
		W !,"<tr class='ListTRD'>"
		W !,"<td class='ListTD1'>",$ZCONVERT(report,"O","HTML"),"</td>"
		W !,"<td class='ListTD2'><button onclick=""doAction('Edit','",$ZCONVERT(report,"O","JS"),"')"">Edit</button></td>"
		W !,"<td class='ListTD2'><button onclick=""doAction('View','",$ZCONVERT(report,"O","JS"),"')"">View</button></td>"
		W !,"<td class='ListTDE'><button onclick=""doAction('List','",$ZCONVERT(report,"O","JS"),"','Delete')""> X </button></td>"
		W !,"</tr>"
		W !,"</tr>"
	}
	W !,"</table>"

	Do ..Footer()
}

ClassMethod NewReport()
{
	Do ..Header("New")
	set report=$Get(%request.Data("report",1))
	// Validate the report name
	
	// If the report already exists move to "EDIT" screen
	if ##class(ompare.Report.Definition).%ExistsId(report) {
		Do ..DisplayPageEditOrNewReport(report)
		Quit
	}
	
	// Does it exist already?
	set fromEnvironment=$Get(%request.Data("fromEnvironment",1))
	
	if fromEnvironment'="" {
		
		//set definition=##class(
		// Save the information
		//set ^ompare("RPTDEF",report,"from")=fromEnvironment
		
		// Allow to configure the rest of the information
		// via "Edit" view
		Do ..DisplayPageEditOrNewReport(report)
		Quit
	} 
	
	
	W !,"<form>"
	W !,"<table class=""frmTable"">"
	W !,"<tr>"
	W !,"<td>Report Name</td>"
	W !,"<td><input type=""text"" value=""",$ZCONVERT(report,"O","HTML"),"""/></td>"
	W !,"<tr>"
	
	W !,"<tr>"
	W !,"<td>Report Name</td>"
	W !,"<td><input type=""text"" value=""",$ZCONVERT(report,"O","HTML"),"""/></td>"
	W !,"<tr>"
	
	W !,"</table>"
	W !,"</form>"
	
	// Validate the From Environment
	
	
	// Display New
	// Enter the ReportName
	// Select the fromEnvironment eg: BASE
	
	// If the environment eg: BASE has been specified then continue to step 2
	
	
	set fromNS="fromNS"
	for {
		set fromNS=$Order(%request.Data(fromNS))
		quit:$E(fromNS,1,6)'="fromNS"
		set ns=$E(fromNS,7,*)
		
		set val=+$G(%request.Data(fromNS,1),"")
		continue:val=0
		
		
	}
	Do ..Footer()
}

ClassMethod DisplayPageEditOrNewReport()
{
	#dim definition as ompare.Report.Definition
	Do ..Header("Edit")
	set report=$Get(%request.Data("report",1))
	set rptnsi="rptns"
	
	set definition=##class(ompare.Report.Definition).%OpenId(report)
	if '$IsObject(definition) set definition=##class(ompare.Report.Definition).%New()
	set definition.ReportName=report
	
	// If DoSave
	set doSave=$G(%request.Data("DoSave",1),0)
	if report'="",doSave {
		// Extensible form save via ReportTypes
		set tSC=definition.PopulateFromHttpRequest()
		if $$$ISERR(tSC) {
			W !,"<H1>Error occured POPULATING Report Definition from form data</H1>"
			W !,!,"<pre>",..ASHTML($SYSTEM.Status.DisplayError(tSC)),"</pre>"
			quit
		}
		set tSC=definition.%Save(1)
		if $$$ISERR(tSC) {
			W !,"<H1>Error occured SAVING Report Definition from form data</H1>"
			W !,!,"<pre>",..ASHTML($SYSTEM.Status.DisplayError(tSC)),"</pre>"
			quit	
		}
	}
	
	if definition.ReportName'="" {
		//W "&nbsp;&nbsp;&nbsp;(<a href=""",,""">Edit</a>)"
		W "&nbsp;&nbsp;&nbsp;<button onclick=""doAction('View','",$ZCONVERT(definition.ReportName,"O","JS"),"')"">View Report</button>"
	}
	
	do definition.DrawEditConfigForm()
	
	Do ..Footer()
	
	//Set %response.TraceDump=1
}

ClassMethod DisplayPageViewReport()
{
	#dim definition as ompare.Report.Definition
	set report=$Get(%request.Data("report",1))
	Set showLinks=$Select(report="_Dynamic":0,1:1)
	Do:showLinks ..Header("View")
	
	do ##class(ompare.Report.Definition).DrawViewReport(report)
	
	Do:showLinks ..Footer()
}

ClassMethod DisplayPageConfig()
{
	Do ..Header("Config")
	
	W !,"<h1>Local Environment Configuration</h1>"
	
	// Save changes for config
	set doSave=+$G(%request.Data("DoSave",1))
	if doSave {
		TSTART
		Do ..SetConfigEnvironmentName(%request.Data("environmentName",1))
		
		// Clear existing 
		Do ..ClearExistingConfigIncludeNamespace()
		
		// Save new values
		set nsp="nsp."
		for {
			set nsp=$Order(%request.Data(nsp))
			quit:$E(nsp,1,4)'="nsp."
			
			Do ..SetConfigIncludeNamespace($P(nsp,".",2,99))
		}
		TCOMMIT
	}
	
	W !,"<form>"
	// Input Text: Environment name
	// Checkbox... is primary
	
	W !,"Environment Name:<input type=""text"" name=""environmentName"" value=""",$ZCONVERT(..GetConfigEnvironmentName(),"O","HTML"),"""/><br/>"
	
	// List Namespaces:
	W !,"<fieldset><legend>Local Reported Namespaces</legend>"
	// Checkbox to include for analysis
	set ns=""
	set checkcount=0
	
	set rsNsp=##class(%ResultSet).%New()
	set rsNsp.ClassName="%SYS.Namespace"
	set rsNsp.QueryName="List"
	
	// P1: Remote=0
	// P2: DontConnect=1
	do rsNsp.Execute(0,1)
	W !,"<table>"
	for {
		quit:'rsNsp.Next()
		set namespace=rsNsp.Data("Nsp")
		
		//set checkcount=checkcount+1
		W !,"<tr>"
		W !,"<td>",$ZCONVERT(namespace,"O","HTML"),"</td>"
		W !,"<td><input name=""nsp."_namespace_""" type=""checkbox"" value=""1""",$Select(..GetConfigIncludeNamespace(namespace):" checked",1:""),"/></td>"
		W !,"</tr>"
		
	}
	do rsNsp.Close()
	W !,"</table>"
	W !,"</fieldset>"
	
	W !,"<input type=""hidden"" name=""DoSave"" value=""1""/>"
	W !,"<input type=""hidden"" name=""Action"" value=""Config""/>"
	W !,"<input type=""submit"" value=""Save""/>"
	W !,"</form>"
	
	Do ..Footer()
}

ClassMethod DisplayPageListXLS()
{
	
	// Handle Delete Report scenario
	// before display list of available WorkBooks.
	set workbook=$Get(%request.Data("report",1))
	set doDelete=$S($Get(%request.Data("P1",1))="Delete":1,1:0)
	if workbook'="",doDelete=1 {
		do ##class(ompare.Report.Workbook).%DeleteId(workbook)
	}
	// End Handle Delete
	Do ..Header("ListXLS")
	
	Do ##class(Workbook).DrawViewList()
	
	Do ..Footer()
}

ClassMethod DisplayPageEditOrNewXLS()
{
	#dim oWorkbook as Workbook
	Do ..Header("EditXLS")
	
	set workbook=$Get(%request.Data("report",1))
	set doSave=$G(%request.Data("DoSave",1),0)
	set oWorkbook=##class(Workbook).%OpenId(workbook,0)
	if '$IsObject(oWorkbook) 
	{
		set oWorkbook=##class(Workbook).%New(workbook)
	}
	if doSave {
		do oWorkbook.PopulateFromHttpRequest()
		
		do oWorkbook.%Save()		
	}
	
	Do oWorkbook.DrawEditConfigForm()
	
	Do ..Footer()
}

ClassMethod DisplayPageViewClassDetail()
{
	// Section Display Details of Properties - if required?
	// Section Display Details of Methods - if required?
}

ClassMethod DisplayPageViewRoutineDetail()
{
	// Display Details of Line Label
	// Same
	// Different
	// Missing
	
	// Environments missing the line label
		
	// Sig1 - Environments
	// Sig2 - Environments
	// SigN - Environments
	
	// Primary environment needed
	/*
	| Primary Environment and Namespace |
	| Label Name | Same | Different | Missing | Extra |
	| 
	| Lable Name: Name of Label in Routine |
	| Same : Other environments where this Label is the same
	| Different: Other environments where the source code of this environment is different
	| Extra: Other environments where this label is not found in the primary comparison site.
	*/
}

ClassMethod DeleteReport(reportName)
{
}

ClassMethod DisplayTemplate(reprotName)
{
}

/// Return an array of environments
/// containing source information for comparison
ClassMethod GetArrayOfEnvironments(exclude As %String = "", Output ary)
{
	// Look at ^ompare("Data",env,ns,"C",[name])=info
	set environment=""
	for {
		set environment=$Order(^ompare("Data",environment))
		quit:environment=""
		continue:environment=exclude
		set ary(environment)=""
	}
}

/// Return an array of namespaces for a given environment
/// containing source information for comparison
ClassMethod GetArrayOfNamespaces(environment As %String = "", Output ary)
{
	Quit:environment=""
	
	// Look at ^ompare("Data",env,ns,"C",[name])=info
	set namespace=""
	for {
		set namespace=$Order(^ompare("Data",environment,namespace))
		quit:namespace=""
		set ary(namespace)=""
	}
}

ClassMethod GetConfigEnvironmentName() As %String
{
	// TODO
	Quit $G(^ompare("Config","env"))
}

ClassMethod SetConfigEnvironmentName(environment As %String = "")
{
	Set ^ompare("Config","env")=environment
}

ClassMethod GetConfigIncludeNamespace(namespace As %String = "") As %Boolean
{
	Quit:namespace="" 0
	Quit +$G(^ompare("Config","ns",namespace))
}

ClassMethod SetConfigIncludeNamespace(namespace As %String = "", include As %Boolean = 1)
{
	Quit:namespace=""
	Set ^ompare("Config","ns",namespace)=+include
}

ClassMethod ClearExistingConfigIncludeNamespace()
{
	Kill ^ompare("Config","ns")
}

// Returns an array of namespaces configured for analysis in this instance

ClassMethod ListConfigIncludeNamespace(Output namespacesArray)
{
	Kill namespacesArray
	merge namespacesArray=^ompare("Config","ns")
	Set namespaceCount=0
	Set namespace=""
	for {
		set namespace=$Order(namespacesArray(namespace))
		Quit:namespace=""
		set namespaceCount=namespaceCount+1
	}
	set namespacesArray=namespaceCount
	Quit
}

ClassMethod GetDateLastIndexed(environment, namespace) As %Integer
{
	Quit:environment="" 0
	Quit:namespace="" 0
	Quit +$P($G(^ompare("Data",environment,namespace)),"^",1)
}

ClassMethod GetTimeLastIndexed(environment, namespace) As %Integer
{
	Quit:environment="" 0
	Quit:namespace="" 0
	Quit +$P($G(^ompare("Data",environment,namespace)),"^",2)
}

ClassMethod GetDateTimeLastIndexed(environment, namespace) As %String
{
	Quit:environment="" ""
	Quit:namespace="" ""
	set dateLastPass=+$P($G(^ompare("Data",environment,namespace)),"^",1)
	set timeLastPass=+$P($G(^ompare("Data",environment,namespace)),"^",2)
	Quit $ZDT(dateLastPass_","_timeLastPass)
}

ClassMethod SetDateTimeLastIndexed(environment, namespace, date, time)
{
	Quit:environment=""
	Quit:namespace=""
	set $P(^ompare("Data",environment,namespace),"^",1)=+date
	set $P(^ompare("Data",environment,namespace),"^",2)=+time
}

ClassMethod GetDateTimeLastAnalysed(environment) As %String
{
	Quit:environment="" ""
	set dateLastPass=+$P($G(^ompare("Data",environment)),"^",1)
	set timeLastPass=+$P($G(^ompare("Data",environment)),"^",2)
	Quit $ZDT(dateLastPass_","_timeLastPass)
}

ClassMethod SetDateTimeLastAnalysed(environment, date = {+$H}, time = {$P($H,",",2)})
{
	Quit:environment=""
	set $P(^ompare("Data",environment),"^",1)=+date
	set $P(^ompare("Data",environment),"^",2)=+time
}

/// Event handler for <b>PreHTTP</b> event: this is invoked before
/// the HTTP headers for a CSP page have been sent.  All changes to the
/// <class>%CSP.Response</class> class, such as adding cookies, HTTP headers,
/// setting the content type etc. must be made from within the OnPreHTTP() method.
/// Also changes to the state of the CSP application such as changing
/// %session.EndSession or %session.AppTimeout must be made within the OnPreHTTP() method.
/// It is prefered that changes to %session.Preserve are also made in the OnPreHTTP() method
/// as this is more efficient, although it is supported in any section of the page.
/// Return <b>0</b> to prevent <method>OnPage</method> from being called.
ClassMethod OnPreHTTP() As %Boolean [ ServerOnly = 1 ]
{
	Set doExport=+$G(%request.Data("DoExport",1))
	
	if doExport {
		Set ^||tmpGzipDevice="exportSig"_$J_".gz"
		
		//do %response.SetHeader("Content-Type","application/binary")
		
		Open ^||tmpGzipDevice:("NWS":/GZIP=1):2
		if ('$Test) {
			Kill ^||tmpGzipDevice
			do %response.SetHeader("Content-Disposition","attachment;filename=CodeFingerprint_"_..GetConfigEnvironmentName()_$TR(..GetDateTimeLastAnalysed(..GetConfigEnvironmentName())," ","T")_".txt")	
		} else {
			do %response.SetHeader("Content-Disposition","attachment;filename=CodeFingerprint_"_..GetConfigEnvironmentName()_$TR(..GetDateTimeLastAnalysed(..GetConfigEnvironmentName())," ","T")_".gz")
			do %response.SetHeader("Content-Type","application/octet-stream")
		}
		
		//Set dev="exportSig"_$J_".gz"
		// Open a tmp file to generate GZIP output
		//Open dev:("NWS","/GZIP=1)
		// If sucessful use the file else use non-compressed appraoch
		// Move file open logic to OnPreHttp to indicate the file content type
		//Do ..ExportToDevice(..GetConfigEnvironmentName())
		//do %response.Flush()
		//Quit $$$OK
	}
	
	Quit $$$OK
}

ClassMethod ASHTML(val) [ CodeMode = expression ]
{
$ZCONVERT(val,"O","HTML")
}

ClassMethod ASJS(val) [ CodeMode = expression ]
{
$ZCONVERT(val,"O","JS")
}

ClassMethod DisplayComment(ByRef lnk)
{
	set sfEnv=$G(lnk("sfEnv"))
	set sfNS=$G(lnk("sfNS"))
	set sfST=$G(lnk("sfST"))
	set sfSTN=$G(lnk("sfSTN"))
	set sfT=$G(lnk("sfT"))
	set sfTN=$G(lnk("sfTN"))
	set stEnv=$G(lnk("stEnv"))
	set stNS=$G(lnk("stNS"))
	set stST=$G(lnk("stST"))
	set stSTN=$G(lnk("stSTN"))
	set stT=$G(lnk("stT"))
	set stTN=$G(lnk("stTN"))
	set T=$S($L(sfT):sfT,1:stT)
 	set TN=$S($L(sfTN):sfTN,1:stTN)
 	set ST=$S($L(sfST):sfST,1:stST)
 	set STN=$S($L(sfSTN):sfSTN,1:stSTN)
 	if $L(sfEnv),$L(sfNS),$L(stEnv),$L(stNS),$L(T),$L(TN),$L(ST),$L(STN) {
	 	set comment=$G(^ompare("DIFFCOMMENT",sfEnv,sfNS,stEnv,stNS,T,TN,ST,STN))
		W:$L(comment) "<div style='background-color:#FFFFAA'>",$ZCVT(comment,"O","HTML"),"</div>"
 	}
}

}

