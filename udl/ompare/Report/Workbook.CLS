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
Class ompare.Report.Workbook Extends %Persistent
{

/// Unique
Property Name As %String;

Property Description As %String(MAXLEN = 15000);

Property DefinitionNames As list Of %String(MAXLEN = 15000);

Property Vendor As %String;

Property Product As %String;

Property CustomerSite As %String;

Index IdxName On Name [ IdKey, PrimaryKey ];

Method OnInit()
{
	// When opening Edit Workbook
	// Remove any Defintions that have since been independently deleted
	set len=..DefinitionNames.Count()
	set ary=""
	set key=""
	for {
		set name=..DefinitionNames.GetNext(.key)
		quit:key=""
		continue:name=""
		continue:'##class(Definition).%ExistsId(name)
		set ary(name)=""
		set x=$I(ary)
	}
	if ary<len {
		do ..DefinitionNames.Clear()
		set name=""
		for {
			set name=$O(ary(name))
			quit:name=""
			do ..DefinitionNames.Insert(name)	
		}
	}
}

Method PopulateFromHttpRequest()
{
	set ..Description=$Get(%request.Data("WorkBookDescription",1))
	set ..Vendor=$Get(%request.Data("Vendor",1))
	set ..Product=$Get(%request.Data("Product",1))
	set ..CustomerSite=$Get(%request.Data("CustomerSite",1))
	
	do ..DefinitionNames.Clear()
	set item=""
	for {
		set item=$Order(%request.Data("workSheet",item),1,data)
		quit:item=""
		do ..DefinitionNames.Insert(data)
	}
}

Method DrawEditConfigForm()
{
	W !,"<form>"
	W !,"<input type=""hidden"" name=""Action"" value=""EditXLS""></input>"
	W !,"<input type=""hidden"" name=""DoSave"" value=""1""></input>"
	W !,"<label>Workbook Name:</label>&nbsp;<input type=""TEXT"" name=""report"" value=""",$ZCONVERT(..Name,"O","HTML"),"""></input>"
	
	W !,"<input type=""Submit"" value=""Save""/><br/>"
	
	if ..Description="" {
		set ..Description="A composite report to identify specific Source Code and Ensemble configuration differences between deployment environments."_$C(13,10)
		set ..Description=..Description_"Each Worksheet represents output for a named comparison report."
	}
	
	
	W !,"Description: <textarea cols='80' rows='5' name='WorkBookDescription'>",$ZCONVERT(..Description,"O","HTML"),"</textarea><br/>"
	W !,"<table>"
	W !,"<tr><td><label>Vendor:</label></td><td><input type=""TEXT"" name=""Vendor"" value=""",$ZCONVERT(..Vendor,"O","JS"),"""></input></td></tr>"
	W !,"<tr><td><label>Product:</label></td><td><input type=""TEXT"" name=""Product"" value=""",$ZCONVERT(..Product,"O","JS"),"""></input></td></tr>"
	W !,"<tr><td><label>Customer Site:</label></td><td><input type=""TEXT"" name=""CustomerSite"" value=""",$ZCONVERT(..CustomerSite,"O","JS"),"""></input></td></tr>"
	W !,"</table>"
	
	// The select doesn't have a name because we are only interested in selected elements
	W !,"<label>Add report items as worksheets</label><select id='selectReport' onchange='reportSelected()'>"
	W !,"<option></option>"
	
	set rs=##class(%ResultSet).%New("ompare.Report.Definition:Extent")
	do rs.Execute()
	for {
		quit:'rs.Next()
		set reportName=rs.Data("ID")
		// Don't display items already selected
		continue:..DefinitionNames.Find(reportName)
		W !,"<option value=""",$ZCONVERT(reportName,"O","HTML"),""">",$ZCONVERT(reportName,"O","HTML"),"</option>"
	}
	W !,"</select>"
	
	W !,"<table id='worksheetList' class='ListT'>"
	W !,"<tr class='ListTRH'>"
	W !,"<th class='ListTH1'>Move UP</th>"
	W !,"<th class='ListTH2'>Sequence</th>"
	W !,"<th class='ListTH3'>Report Name</th>"
	W !,"<th class='ListTHE'>Remove</th>"
	W !,"</tr>"
	
	W !,"</table>"

	W !,"</form>"
	
	W !,"<script>"
	
	// Just swaps the text around. Don't need to actually move the rows.
	W !,"function moveUp(worksheetRow2) {"
	W !,"if (!worksheetRow2) { return;}"
	W !,"var rowIndex=worksheetRow2.rowIndex;"
	W !,"if (rowIndex<2) {return;}"
	
	// Swap the input values in cell 2 for this and the preceeding given row
	W !,"var worksheetList=document.getElementById('worksheetList');"
	W !,"if (!worksheetList) {return;}"
	W !,"var worksheetRow1=worksheetList.rows[rowIndex-1];"
	W !,"if (!worksheetRow1) {return;}"

	W !,"var worksheetCell1=worksheetRow1.cells[2];"
	W !,"if (!worksheetCell1) {return;}"
	W !,"var worksheetCell2=worksheetRow2.cells[2];"
	W !,"if (!worksheetCell2) {return;}"
		
	W !,"var tmpText=worksheetCell1.childNodes[0].value;"
	W !,"worksheetCell1.childNodes[0].value=worksheetCell2.childNodes[0].value;"
	W !,"worksheetCell2.childNodes[0].value=tmpText;"
	W !,"}"
	// Creates new rows in the table with the select option text
	// Deletes the specified option from the select list
	// Ie: An option is unique and is only added to the table once
	W !,"function reportSelected() {"
	W !,"  var sel=document.getElementById('selectReport');"
	W !,"  if (sel.value!='') {"
	W !,"    var reportText=sel.value;"
	W !,"    sel.remove(sel.selectedIndex);"
	W !,"    sel.value='';"
	W !,"  }"
	W !,"  addRow(reportText);"
	W !,"}"
	
	W !,"function addRow(reportText)"
	W !,"{"
	W !,"  var worksheetList=document.getElementById('worksheetList');"
	W !,"  if (!worksheetList) { return;}"
		// Add the new row to the end
	W !,"  var worksheetRow=worksheetList.insertRow(-1);"
	W !,"  worksheetRow.className='ListTRD';"
	W !,"  var td1=worksheetRow.insertCell(0);"
	W !,"  td1.className='ListTD1';"
		
	W !,"  if ((worksheetRow.rowIndex)>1) {"
	W !,"    var btn1=document.createElement('BUTTON');"
	W !,"    btn1.value='&nbsp;^&nbsp;';"
	W !,"    btn1.innerText=' ^ ';"
	// The row index may change if a row is deleted in front of this one
	W !,"    btn1.onclick=function() {moveUp(worksheetRow);};"
	W !,"    td1.appendChild(btn1);"
	W !,"    } else {"
	W !,"    td1.innerHTML=' - ';"
	W !,"  }"
		
	W !,"  var td2=worksheetRow.insertCell(1);"
	W !,"  td2.className='ListTD2';"
	// Dynamically set the sequence number from current row index
	W !,"  td2.innerHTML=worksheetRow.rowIndex;"
	W !,"  var td3=worksheetRow.insertCell(2);"
	W !,"  td3.className='ListTD2';"
	// Use INPUT beacuse we want to post data
	// Not interested in unique %request variable name
	W !,"  var input1=document.createElement('INPUT');"
	W !,"  input1.readonly=1;"
	W !,"  input1.name=('workSheet');"
	W !,"  input1.type='TEXT';"
	W !,"  input1.readOnly=1;"
	W !,"  input1.value=reportText;"
	W !,"  input1.size=50;"
	W !,"  td3.appendChild(input1);"
		
	W !,"  var td4=worksheetRow.insertCell(3);"
	W !,"  td4.className='ListTDE';"
	W !,"  var btn2=document.createElement('BUTTON');"
	W !,"  btn2.value=' X ';"
	W !,"  btn2.innerText=' X ';"
	W !,"  btn2.Class='.btnDel';"
	W !,"  btn2.Style='Height:15;Width:15';"
	// Because the row index may change if rows are deleted before this one
	W !,"  btn2.onclick=function() {returnSelected(worksheetRow);}"
	W !,"  td4.appendChild(btn2);"
	W !,"}"
	
	// Deletes the specified option from the table
	// Re-creates the option in the Select list again
	W !,"function returnSelected(worksheetRow) {"
	// Get the text value for a selected item
	W !,"  var worksheetList=document.getElementById('worksheetList');"
	W !,"  if (!worksheetList) {return;}"
	W !,"  var worksheetCell=worksheetRow.cells[2];"
	W !,"  if (!worksheetCell) {return;}"
	W !,"  var reportText=worksheetCell.childNodes[0].value;"
	W !,"  if (reportText=='') { return;}"
	W !,"  var selectReport=document.getElementById('selectReport');"
	W !,"  if (!selectReport) { return;}"
	W !,"  var option1=document.createElement('option');"
	W !,"  if (!option1) { return;}"
	W !,"  option1.text=reportText;"
	W !,"  option1.value=reportText;"
	W !,"  selectReport.add(option1);"
		
	W !,"  var worksheetCell;"
	// If deleting the first row
	// be sure to remove the "MoveUp" button for the new "First" data row
	W !,"  if ((worksheetRow.rowIndex==1)&&(worksheetList.rows.length>2)) {"
	W !,"  var worksheetRowNext=worksheetList.rows[2];"
	W !,"  worksheetCell=worksheetRowNext.cells[0];"
	W !,"  worksheetCell.innerHTML=' - ';"
	W !,"}"
		
	// delete the row
	W !,"  worksheetList.deleteRow(worksheetRow.rowIndex);"
		
	// Reassign sequence number
	W !,"  var numberOfRows=worksheetList.rows.length"
		
	W !,"  for (var rowNumber=1;rowNumber<numberOfRows;rowNumber++)"
	W !,"  {"
	W !,"    worksheetRow=worksheetList.rows[rowNumber];"
	W !,"    worksheetCell=worksheetRow.cells[1];"
	W !,"    worksheetCell.innerHTML=rowNumber;"
	W !,"  }"
	W !,"}"
	
	if ..DefinitionNames.Count()>0 {
		// We wish to add rows programatically on the client so we can use rowIndex instead of static ID's to manage order of table items.
		W !,"function loadTable(event) {"
		W !,"  ;"  // Expect to have 
		set key="",workSheet=""
		for {
			set workSheet=..DefinitionNames.GetNext(.key)
			quit:key=""
			continue:workSheet=""
			W !,"  addRow('",$ZCONVERT(workSheet,"O","JS"),"');"
		}
		W !,"}"
		W !,"if (window.addEventListener) {"
		W !,"  window.addEventListener('load',loadTable);"
		W !,"} else if (window.attachEvent) {"
		// Internet Explorer 8 / 9
		W !,"  window.attachEvent('onload',loadTable);"
		W !,"}"
	}
	
	W !,"</script>"
}

ClassMethod DrawViewList()
{
	// Display a list of existing Templates
	W !,"<table class='ListT'>"
	W !,"<tr class='ListTRH'>"
	W !,"<th class='ListTH1'>Workbook Name</th>"
	W !,"<th class='ListTH2'>Edit</th>"
	W !,"<th class='ListTH2'>View</th>"
	W !,"<th class='ListTHE'>Delete</th>"
	W !,"</tr>"
	
	// Use built in extent query
	set rs=##class(%ResultSet).%New("ompare.Report.Workbook:Extent")
	do rs.Execute()
	for {
		quit:'rs.Next()
		set name=rs.Data("ID")
		W !,"<tr class='ListTRD'>"
		W !,"<td class='ListTD1'>",$ZCONVERT(name,"O","HTML"),"</td>"
		W !,"<td class='ListTD2'><button onclick=""doAction('EditXLS','",$ZCONVERT(name,"O","JS"),"')"">Edit</button></td>"
		W !,"<td class='ListTD2'><a href='ompare.Report.ExportExcelWorkbook.cls?WorkBook=",$ZCONVERT(name,"O","URL"),"' target='_blank'/>Excel Export</a></td>"
		W !,"<td class='ListTDE'><button onclick=""doAction('ListXLS','",$ZCONVERT(name,"O","JS"),"','Delete')""> X </button></td>"
		W !,"</tr>"
	}
	W !,"</table>"
}

/// This callback method is invoked by the <METHOD>%New</METHOD> method to 
/// provide notification that a new instance of an object is being created.
/// 
/// <P>If this method returns an error then the object will not be created.
/// <p>It is passed the arguments provided in the %New call.
/// When customizing this method, override the arguments with whatever variables and types you expect to receive from %New().
/// For example, if you're going to call %New, passing 2 arguments, %OnNew's signature could be:
/// <p>Method %OnNew(dob as %Date = "", name as %Name = "") as %Status
/// If instead of returning a %Status code this returns an oref and this oref is a subclass of the current
/// class then this oref will be the one returned to the caller of %New method.
Method %OnNew(name As %String = "") As %Status [ Private, ServerOnly = 1 ]
{
	set ..Name=name
	Quit $$$OK
}

/// This callback method is invoked by the <METHOD>%Open</METHOD> method to 
/// provide notification that the object specified by <VAR>oid</VAR> is being opened.
/// 
/// <P>If this method returns an error then the object will not be opened.
Method %OnOpen() As %Status [ Private, ServerOnly = 1 ]
{
	do ..OnInit()
	Quit $$$OK
}

Storage Default
{
<Data name="WorkbookDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="3">
<Value>Description</Value>
</Value>
<Value name="4">
<Value>DefinitionNames</Value>
</Value>
<Value name="5">
<Value>Vendor</Value>
</Value>
<Value name="6">
<Value>Product</Value>
</Value>
<Value name="7">
<Value>CustomerSite</Value>
</Value>
</Data>
<DataLocation>^ompare.Report.WorkbookD</DataLocation>
<DefaultData>WorkbookDefaultData</DefaultData>
<IdLocation>^ompare.Report.WorkbookD</IdLocation>
<IndexLocation>^ompare.Report.WorkbookI</IndexLocation>
<StreamLocation>^ompare.Report.WorkbookS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

