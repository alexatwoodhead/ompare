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
/// Serverside component for reporting
/// Does NOT need to be deploying to target servers for profiling source signatures and 
/// optional capturing source detail
/// Extensible configuration and processing for ReportTypes eg: Class, Lookup, Mapping, Routine, SQL<br/>
/// The report frameworks leverages the following conventions:<ul>
/// <li>Use the Parameter prefix "RPTType*" for the distinct Report type code</li>
/// <li>Use one or more Parameter prefix "RPTSubType*" to code for components within a large document type or configuration</li>
/// </ul>
/// Methods that may be overriden in subclasses
/// <table class="Summary" border="0" cellspacing="0" cellpadding="1">
/// <tr><th>Method name</th><th>Description</th></tr>
/// <tr><td>CreateDynamicReport</td><td>Generates a report defintion on the fly for a single code item</td></tr>
/// <tr><td>DrawDetailAltText</td><td>Draw detailed difference breakdown in HTML report</td></tr>
/// <tr><td>DrawDetailAltTextWithLink</td><td>Draw detailed difference breakdown in HTML report with hyperlinks to drill down code / config difference</td></tr>
/// <tr><td>DrawEditConfigForm</td><td>Draw HTML for Inputs and TextAreas to configuring this information area of a report definition</td></tr>
/// <tr><td>DrawExcelReportSection</td><td>Draw XML for spreadsheet rows that include information for this report type</td></tr>
/// <tr><td>DrawReport</td><td>Draw XML for spreadsheet rows that include information for this report type</td></tr>
/// <tr><td>IsEmptyReport</td><td>Used to determine whether a defintion includes a section of information for this report type</td></tr>
/// <tr><td>IsEmptyReportType</td><td>Used to determine whether a defintion includes a section of information for this report type</td></tr>
/// <tr><td>PopulateFromHttpRequest</td><td>Load settings from a Config web page post ("Save" action)</td></tr>
/// <tr><td>PopulateReportParams</td><td>Transfers settings for this report type to a defintion for generic difference processing</td></tr>
/// </table>
Class ompare.ReportType.Base Extends %Persistent
{

Parameter RPTSame = 1;

Parameter RPTDifferent = 2;

Parameter RPTMissing = 3;

Parameter RPTExtra = 4;

Parameter RPTMapped = 5;

Parameter RPTSourceControlled = 6;

/// Generic Sub Type
Parameter RPTSubTypeConfig = "CFG";

/// Generic Item
Parameter RPTItemConfigMapped = "IsMapped";

/// Generic Item
Parameter RPTItemConfigSourceControlled = "IsSourceControlled";

/// Ensure this Code doesn't collide with other sub-class implementations of Base
/// Eg: "cls" abbreviation for class
Parameter DocumentType As %String;

Parameter PageSourceView = "ompare.Report.SourceView.cls?";

Parameter PageAnchor = "Configure parameter PageAnchorName";

/// Mechanism to rearrage sort order
Parameter ReportOrder = 99;

Parameter eol = "&#10;";

/// Called from ompare.Report.Defintion on subclass on ompare.ReportType.Base
/// Override in subclass
ClassMethod CreateDynamicReport(name As %String) As ompare.ReportType.Base
{
	Quit ..%New()
}

/// Override to return true if the document type is managed by subclass
ClassMethod IsDynamicReportType(document As %String) As %Boolean
{
	Quit 0
}

/// Called from ompare.Report.Defintion on subclass on ompare.ReportType.Base
/// Override in subclass
Method PopulateReportParams(ByRef summary, ByRef detail, ByRef exclude, ByRef include)
{
}

Method PopulateFromHttpRequest()
{
}

Method DrawEditConfigForm()
{
}

Method DrawReport(definition As ompare.Report.Definition, isFirstDisplayed As %Boolean = 0)
{
}

Method DrawReportAchor()
{
	W !,"<a href=""#show",..#PageAnchor,""">",..#PageAnchor,"</a>&nbsp;| "
}

Method IsEmptyReport() As %Boolean
{
	Q 1
}

Method IsEmptyReportType(type As %String) As %Boolean
{
	Q 1
}

Method IsDocumentType(type As %String) As %Boolean
{
	quit type=..#DocumentType
}

ClassMethod GetDateTimeOfData(env) As %String
{
	Quit:env="" ""
	set date=+$P($G(^ompare("Data",env)),"^")
	Quit:date=0 ""
	set time=+$P($G(^ompare("Data",env)),"^",2)
	Quit:time=0 ""
	Quit $ZDT(date_","_time,3)
}

ClassMethod ASHTML(val) [ CodeMode = expression ]
{
$ZCONVERT(val,"O","HTML")
}

ClassMethod RTPEnumToText(val) [ CodeMode = expression ]
{
$Case(val,..#RPTSame:"Same",..#RPTDifferent:"Different",..#RPTMissing:"Missing",..#RPTExtra:"Extra",:" - ")
}

ClassMethod SpreadsheetReportDetailText(type = "", name = "", env = "")
{
	set return=""
	set out=""
	quit:type="" "type is empty"
	quit:name="" "name is empty"
	quit:env="" "env is empty"
	
	set sec=0
	set subname=""
	
	
	set subtype=""
	for {
		set subtype=$O(^||ReportData(type,name,"d",subtype))
		quit:subtype=""
		
		for {
			set subname=$Order(^||ReportData(type,name,"d",subtype,subname))
			quit:subname=""
		
			set ns=$Order(^||ReportData(type,name,"d",subtype,subname,env,""),+1,result)
			continue:ns=""
		
			set next=$I(out(subtype))
			set out(subtype,next,"name")=subname
			set out(subtype,next,"result")=result
		}
	}
	set first=1
	
	/* Add customizations here 
	if +$G(out(..#RPTSubTypeSummary))>0 {
		W:'first ..#eol
		S first=0
		W ..XMLO("Summary: (Differences)")
		// TODO: List count differences??
		for i=1:1:out(..#RPTSubTypeSummary) {
			W ..#eol,..XMLO(" *"_out(..#RPTSubTypeSummary,i,"name")_" ("_..RTPEnumToText(out(..#RPTSubTypeSummary,i,"result"))_")")
		}
	}
		
	*/
	
	Quit
}

ClassMethod ReportDetailAltText(type = "", name = "", env = "", eol = {$C(10)})
{
	// ^||ReportData(type,name,"d",subtype,subname,toEnv,toNs)
	set return=""
	set out=""
	quit:type="" "type is empty"
	quit:name="" "name is empty"
	quit:env="" "env is empty"
	
	set sec=0
	set subname=""
	set subtype=""
	for {
		set subtype=$O(^||ReportData(type,name,"d",subtype))
		quit:subtype=""
		
		for {
			set subname=$Order(^||ReportData(type,name,"d",subtype,subname))
			quit:subname=""
		
			set ns=$Order(^||ReportData(type,name,"d",subtype,subname,env,""),+1,result)
			continue:ns=""
		
			set next=$I(out(subtype))
			set out(subtype,next,"name")=subname
			set out(subtype,next,"result")=result
		}
	}
	quit ..DrawDetailAltText(.out, return, eol)
}

ClassMethod DrawDetailAltText(ByRef out, return As %String, eol)
{
	quit ""
}

ClassMethod ReportDetailAltTextWithLink(type = "", name = "", env = "", eol = "<br/>", ByRef lnk, result = "", displayComments As %Boolean = 0)
{
	set return=""
	set out=""
	quit:type="" "type is empty"
	quit:name="" "name is empty"
	quit:env="" "env is empty"
	
	set sec=0
	set subname=""
	if $Data(^||ReportData(type,name,"d"))=0
	{
		W "(",..AddSourceLink(..RTPEnumToText(..#RPTDifferent),.lnk,result),")"
		Quit ""
	}
	set subtype=""
	for {
		set subtype=$O(^||ReportData(type,name,"d",subtype))
		quit:subtype=""
		
		for {
			set subname=$Order(^||ReportData(type,name,"d",subtype,subname))
			quit:subname=""
		
			set ns=$Order(^||ReportData(type,name,"d",subtype,subname,env,""),+1,result)
			continue:ns=""
		
			set next=$I(out(subtype))
			set out(subtype,next,"name")=subname
			set out(subtype,next,"result")=result
		}
	}
	// Pass on to ReportType specific implementation
	do ..DrawDetailAltTextWithLink(.out, return,.lnk,eol,displayComments)
	quit ""
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

/// Override in ReportType
ClassMethod DrawDetailAltTextWithLink(ByRef out, return As %String, ByRef lnk, eol, displayComments)
{
}

ClassMethod AddSourceLink(label = "", ByRef lnk, result)
{
	W "<a href="""_..#PageSourceView
	s k=""
	s start=1
	for {
		set k=$O(lnk(k))
		q:k=""
		if $E(k,1,2)="sf",result'=..#RPTDifferent,result'=..#RPTMissing,result'=..#RPTSame continue
		w:'start "&"
		W k,"=",$ZCONVERT($G(lnk(k)),"O","URL")
		s start=0
	}
	W """ target=""_blank"">",label,"</a>"
	Quit ""
}

/// Add new sections to generated Excel Report projection
/// Subclass in ompare.ReportType.[ViewName]
ClassMethod DrawExcelReportSection(definition As ompare.Report.Definition, numberofenvironments As %Integer = 0, reportType As ompare.ReportType.Base)
{
	// TO DO
}

ClassMethod XMLO(val) [ CodeMode = expression ]
{
$ZCVT(val,"O","XML")
}

Storage Default
{
<Data name="BaseDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^ompare.ReportType.BaseD</DataLocation>
<DefaultData>BaseDefaultData</DefaultData>
<IdLocation>^ompare.ReportType.BaseD</IdLocation>
<IndexLocation>^ompare.ReportType.BaseI</IndexLocation>
<StreamLocation>^ompare.ReportType.BaseS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

