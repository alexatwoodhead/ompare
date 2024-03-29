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
Class ompare.ReportType.Mapping Extends ompare.ReportType.Base
{

Parameter RPTTypeMapping = "NSMAP";

Parameter RPTSubTypeMappingGlobal = "GBL";

Parameter RPTSubTypeMappingRoutine = "ROU";

Parameter RPTSubTypeMappingPackage = "PKG";

Property SummaryShowSameMaps As %Boolean [ InitialExpression = 1 ];

Property SummaryShowDifferentMaps As %Boolean [ InitialExpression = 1 ];

Property SummaryShowMissingMaps As %Boolean [ InitialExpression = 1 ];

Property SummaryShowExtraMaps As %Boolean [ InitialExpression = 1 ];

Property DetailShowSameMapsGlobal As %Boolean [ InitialExpression = 0 ];

Property DetailShowDifferentMapsGlobal As %Boolean [ InitialExpression = 1 ];

Property DetailShowMissingMapsGlobal As %Boolean [ InitialExpression = 1 ];

Property DetailShowExtraMapsGlobal As %Boolean [ InitialExpression = 1 ];

Property DetailShowSameMapsRoutine As %Boolean [ InitialExpression = 0 ];

Property DetailShowDifferentMapsRoutine As %Boolean [ InitialExpression = 1 ];

Property DetailShowMissingMapsRoutine As %Boolean [ InitialExpression = 1 ];

Property DetailShowExtraMapsRoutine As %Boolean [ InitialExpression = 1 ];

Property DetailShowSameMapsPackage As %Boolean [ InitialExpression = 0 ];

Property DetailShowDifferentMapsPackage As %Boolean [ InitialExpression = 1 ];

Property DetailShowMissingMapsPackage As %Boolean [ InitialExpression = 1 ];

Property DetailShowExtraMapsPackage As %Boolean [ InitialExpression = 1 ];

Parameter PageAnchor = "Maps";

/// Called from ompare.Report.Defintion on subclass on ompare.ReportType.Base
/// Override in subclass
Method PopulateReportParams(ByRef config, ByRef summary, ByRef detail, ByRef exclude, ByRef include)
{
	set:..SummaryShowSameMaps summary(..#RPTTypeMapping,..#RPTSame)=""
	set:..SummaryShowDifferentMaps summary(..#RPTTypeMapping,..#RPTDifferent)=""
	set:..SummaryShowMissingMaps summary(..#RPTTypeMapping,..#RPTMissing)=""
	set:..SummaryShowExtraMaps summary(..#RPTTypeMapping,..#RPTExtra)=""
	
	set:..DetailShowSameMapsGlobal detail(..#RPTSubTypeMappingGlobal,..#RPTSame)=""
	set:..DetailShowDifferentMapsGlobal detail(..#RPTSubTypeMappingGlobal,..#RPTDifferent)=""
	set:..DetailShowMissingMapsGlobal detail(..#RPTSubTypeMappingGlobal,..#RPTMissing)=""
	set:..DetailShowExtraMapsGlobal detail(..#RPTSubTypeMappingGlobal,..#RPTExtra)=""
	
	set:..DetailShowSameMapsRoutine detail(..#RPTSubTypeMappingRoutine,..#RPTSame)=""
	set:..DetailShowDifferentMapsRoutine detail(..#RPTSubTypeMappingRoutine,..#RPTDifferent)=""
	set:..DetailShowMissingMapsRoutine detail(..#RPTSubTypeMappingRoutine,..#RPTMissing)=""
	set:..DetailShowExtraMapsRoutine detail(..#RPTSubTypeMappingRoutine,..#RPTExtra)=""
	
	set:..DetailShowSameMapsPackage detail(..#RPTSubTypeMappingPackage,..#RPTSame)=""
	set:..DetailShowDifferentMapsPackage detail(..#RPTSubTypeMappingPackage,..#RPTDifferent)=""
	set:..DetailShowMissingMapsPackage detail(..#RPTSubTypeMappingPackage,..#RPTMissing)=""
	set:..DetailShowExtraMapsPackage detail(..#RPTSubTypeMappingPackage,..#RPTExtra)=""
}

Method PopulateFromHttpRequest()
{
	set ..SummaryShowSameMaps=$G(%request.Data(..#RPTTypeMapping_"SummaryShowSameMaps",1),0)
	set ..SummaryShowDifferentMaps=$G(%request.Data(..#RPTTypeMapping_"SummaryShowDifferentMaps",1),0)
	set ..SummaryShowMissingMaps=$G(%request.Data(..#RPTTypeMapping_"SummaryShowMissingMaps",1),0)
	set ..SummaryShowExtraMaps=$G(%request.Data(..#RPTTypeMapping_"SummaryShowExtraMaps",1),0)
	set ..DetailShowSameMapsGlobal=$G(%request.Data(..#RPTTypeMapping_"DetailShowSameMapsGlobal",1),0)
	set ..DetailShowDifferentMapsGlobal=$G(%request.Data(..#RPTTypeMapping_"DetailShowDifferentMapsGlobal",1),0)
	set ..DetailShowMissingMapsGlobal=$G(%request.Data(..#RPTTypeMapping_"DetailShowMissingMapsGlobal",1),0)
	set ..DetailShowExtraMapsGlobal=$G(%request.Data(..#RPTTypeMapping_"DetailShowExtraMapsGlobal",1),0)
	set ..DetailShowSameMapsRoutine=$G(%request.Data(..#RPTTypeMapping_"DetailShowSameMapsRoutine",1),0)
	set ..DetailShowDifferentMapsRoutine=$G(%request.Data(..#RPTTypeMapping_"DetailShowDifferentMapsRoutine",1),0)
	set ..DetailShowMissingMapsRoutine=$G(%request.Data(..#RPTTypeMapping_"DetailShowMissingMapsRoutine",1),0)
	set ..DetailShowExtraMapsRoutine=$G(%request.Data(..#RPTTypeMapping_"DetailShowExtraMapsRoutine",1),0)
	set ..DetailShowSameMapsPackage=$G(%request.Data(..#RPTTypeMapping_"DetailShowSameMapsPackage",1),0)
	set ..DetailShowDifferentMapsPackage=$G(%request.Data(..#RPTTypeMapping_"DetailShowDifferentMapsPackage",1),0)
	set ..DetailShowMissingMapsPackage=$G(%request.Data(..#RPTTypeMapping_"DetailShowMissingMapsPackage",1),0)
	set ..DetailShowExtraMapsPackage=$G(%request.Data(..#RPTTypeMapping_"DetailShowExtraMapsPackage",1),0)
}

Method DrawEditConfigForm()
{
	W !,"<fieldset><legend>Namespace Mapping Configuration</legend>"
	W !,"Show Same Maps <input name=""",..#RPTTypeMapping,"SummaryShowSameMaps"" type=""checkbox"" value=""1""",$Select(..SummaryShowSameMaps:" checked",1:""),"/><br/>"
	W !,"Show Different Maps <input name=""",..#RPTTypeMapping,"SummaryShowDifferentMaps"" type=""checkbox"" value=""1""",$Select(..SummaryShowDifferentMaps:" checked",1:""),"/><br/>"
	W !,"Show Missing Maps <input name=""",..#RPTTypeMapping,"SummaryShowMissingMaps"" type=""checkbox"" value=""1""",$Select(..SummaryShowMissingMaps:" checked",1:""),"/><br/>"
	W !,"Show Extra Maps <input name=""",..#RPTTypeMapping,"SummaryShowExtraMaps"" type=""checkbox"" value=""1""",$Select(..SummaryShowExtraMaps:" checked",1:""),"/><br/>"
	W !,"<fieldset><legend>Global Maps</legend>"
	W !,"Show Same Globals <input name=""",..#RPTTypeMapping,"DetailShowSameMapsGlobal"" type=""checkbox"" value=""1""",$Select(..DetailShowSameMapsGlobal:" checked",1:""),"/><br/>"
	W !,"Show Different Globals <input name=""",..#RPTTypeMapping,"DetailShowDifferentMapsGlobal"" type=""checkbox"" value=""1""",$Select(..DetailShowDifferentMapsGlobal:" checked",1:""),"/><br/>"
	W !,"Show Missing Globals <input name=""",..#RPTTypeMapping,"DetailShowMissingMapsGlobal"" type=""checkbox"" value=""1""",$Select(..DetailShowMissingMapsGlobal:" checked",1:""),"/><br/>"
	W !,"Show Extra Globals <input name=""",..#RPTTypeMapping,"DetailShowExtraMapsGlobal"" type=""checkbox"" value=""1""",$Select(..DetailShowExtraMapsGlobal:" checked",1:""),"/><br/>"
	W !,"</fieldset>"
	W !,"<fieldset><legend>Routine Maps</legend>"
	W !,"Show Same Routines <input name=""",..#RPTTypeMapping,"DetailShowSameMapsRoutine"" type=""checkbox"" value=""1""",$Select(..DetailShowSameMapsRoutine:" checked",1:""),"/><br/>"
	W !,"Show Different Routines <input name=""",..#RPTTypeMapping,"DetailShowDifferentMapsRoutine"" type=""checkbox"" value=""1""",$Select(..DetailShowDifferentMapsRoutine:" checked",1:""),"/><br/>"
	W !,"Show Missing Routines <input name=""",..#RPTTypeMapping,"DetailShowMissingMapsRoutine"" type=""checkbox"" value=""1""",$Select(..DetailShowMissingMapsRoutine:" checked",1:""),"/><br/>"
	W !,"Show Extra Routines <input name=""",..#RPTTypeMapping,"DetailShowExtraMapsRoutine"" type=""checkbox"" value=""1""",$Select(..DetailShowExtraMapsRoutine:" checked",1:""),"/><br/>"
	W !,"</fieldset>"
	W !,"<fieldset><legend>Package Maps</legend>"
	W !,"Show Same Packages <input name=""",..#RPTTypeMapping,"DetailShowSameMapsPackage"" type=""checkbox"" value=""1""",$Select(..DetailShowSameMapsPackage:" checked",1:""),"/><br/>"
	W !,"Show Different Packages <input name=""",..#RPTTypeMapping,"DetailShowDifferentMapsPackage"" type=""checkbox"" value=""1""",$Select(..DetailShowDifferentMapsPackage:" checked",1:""),"/><br/>"
	W !,"Show Missing Packages <input name=""",..#RPTTypeMapping,"DetailShowMissingMapsPackage"" type=""checkbox"" value=""1""",$Select(..DetailShowMissingMapsPackage:" checked",1:""),"/><br/>"
	W !,"Show Extra Packages <input name=""",..#RPTTypeMapping,"DetailShowExtraMapsPackage"" type=""checkbox"" value=""1""",$Select(..DetailShowExtraMapsPackage:" checked",1:""),"/><br/>"
	W !,"</fieldset>"
	W !,"</fieldset>"
}

Method DrawReport(definition As ompare.Report.Definition, isFirstDisplayed As %Boolean = 0)
{
	quit:..IsEmptyReport()
	set elapstart=$P($ZTS,",",2)
	// Show Instance Mapping Table
	W !,"<span class=""SectionTitle"">Section: Namespace Mappings</span>"
	W !,"<a name=""showMaps""></a>"
	W:'isFirstDisplayed "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[<a href=""#showTop"">Back to Top</a>]"
	// TABLE for Mapping
	W !,"<table border=1>"
	W !," <tr>"
	W !,"  <th>Map Name</th>"
	//  Put From Environment as the first column
	W !,"  <th>",definition.FromEnvironment,"</th>"
	set env=""
	for {
		set env=$Order(^||ReportData("Meta","To",env),+1,date)
		quit:env=""
		W !,"  <th>",$ZCONVERT(env,"O","HTML"),"<br/>",$ZD(date,3),"</th>"
	}
	W !," <tr>"
	
	for mapname="Default","Globals","Routines","Packages" {
		W !," <tr>"
		W !,"  <td>",$ZCONVERT(mapname,"O","HTML"),"</td>"
		
		set toNs=$O(^||ReportData(..#RPTTypeMapping,mapname,"s",definition.FromEnvironment,""),+1,result)
		if toNs="" {
			W "<td> - </td>"
		} else {
			W "<td>",$Case(result,..#RPTSame:"Same",..#RPTDifferent:"Different",..#RPTMissing:"Missing",..#RPTExtra:"Extra",:" - "),"</td>"
		}
		
		set env=""
		for {
			set env=$Order(^||ReportData("Meta","To",env),+1,date)
			quit:env=""
		
			set toNs=$O(^||ReportData(..#RPTTypeMapping,mapname,"s",env,""),+1,result)
			if toNs="" {
				W "<td> - </td>"
			} else {
				
				W "<td style=""vertical-align:top"">"
				k lnk
				set lnk("sfEnv")=definition.FromEnvironment
				set lnk("sfNS")=$Select($D(lnk("sfEnv")):$O(definition.EnvironmentsMD(lnk("sfEnv"),"")),1:"")
				set lnk("sfT")=..#RPTTypeMapping
				set lnk("sfTN")=mapname
				kill lnk("sfST")
				kill lnk("sfSTN")
				if definition.HistoricView {
					set lnk("stD")=date
					set lnk("stEnv")=$ZSTRIP($P(env,"("),">W")  // Remove History Discriptor
				} else {
					kill lnk("stD")
					set lnk("stEnv")=env
				}
				set lnk("stNS")=$Select($D(lnk("stEnv")):$O(definition.EnvironmentsMD(lnk("stEnv"),"")),1:"")
				set lnk("stT")=..#RPTTypeMapping
				set lnk("stTN")=mapname
				kill lnk("stST")
				kill lnk("stSTN")
				
				if result=..#RPTDifferent {
					do ..AddSourceLink("Differences",.lnk,..#RPTDifferent)
				} elseif result=..#RPTExtra {
					do ..AddSourceLink("Extra",.lnk,..#RPTDifferent)
				} elseif result=..#RPTMissing {
					W "Missing"	
				} elseif result=..#RPTSame {	
					do ..AddSourceLink("Same",.lnk,..#RPTSame)
				}		
				W "</td>"
			}
		}
		W !," </tr>"
	}
	W !,"</table>"
	set elapend=$P($ZTS,",",2)
	W !,"(Time taken:",$FN(elapend-elapstart,"",2)," seconds)"
	W !,"<hr/>"
}

Method IsEmptyReport() As %Boolean
{
	Quit:..SummaryShowSameMaps 0
	Quit:..SummaryShowDifferentMaps 0
	Quit:..SummaryShowMissingMaps 0
	Quit:..SummaryShowExtraMaps 0
	Quit 1
}

Method IsEmptyReportType(type As %String) As %Boolean
{
	Quit:type'=..#RPTTypeMapping 1
	Quit ..IsEmptyReport()
}

/// Add new sections to generated Excel Report projection
/// Subclass in ompare.ReportType.[ViewName]
ClassMethod DrawExcelReportSection(definition As ompare.Report.Definition, numberofenvironments As %Integer = 0, reportType As ompare.ReportType.Base)
{
	// TO DO
	set sequenceNumber=0
 	W !,"<Row>"
 	for i=0:1:numberofenvironments+1 { W "<Cell ss:StyleID=""s64""></Cell>" }
 	W !,"</Row>"
 
	 for i=1:1:2 {
 		W !,"<Row ss:AutoFitHeight=""0"" ss:StyleID=""s62"">"
 		if i=1 {
	 		W !,"<Cell ss:StyleID=""s64""><Data ss:Type=""String""></Data></Cell>"  //seq
		 	W !,"<Cell ss:StyleID=""s64""><Data ss:Type=""String""></Data></Cell>"
			W !,"<Cell ss:StyleID=""s64""><Data ss:Type=""String"">",..XMLO(definition.FromEnvironment),"</Data></Cell>" 	
 		} else {
			W !,"<Cell ss:StyleID=""s64""><Data ss:Type=""String"">Item</Data></Cell>"  //seq
 			W !,"<Cell ss:StyleID=""s64""><Data ss:Type=""String"">Namespace Map</Data></Cell>"
 			W !,"<Cell ss:StyleID=""s64""><Data ss:Type=""String"">",definition.GetDateTimeOfData(definition.FromEnvironment),"</Data></Cell>"
  		}
  		set env="",key=""
  		for {
			set env=definition.Environments.GetNext(.key)
			quit:key=""
			continue:'$IsObject(env)
			continue:definition.FromEnvironment=env.Name
			if i=1 {
				W !,"<Cell ss:StyleID=""s64""><Data ss:Type=""String"">",..XMLO(env.Name),"</Data></Cell>" 	
 			} else {
				W !,"<Cell ss:StyleID=""s64""><Data ss:Type=""String"">",definition.GetDateTimeOfData(env),"</Data></Cell>"
  			}
 		}
 		W !,"</Row>" 	
 	}
 
 	if $Data(^||ReportData(..#RPTTypeMapping))=0 {	 	
	 	Do ##class(ompare.Report.ExportExcelWorkbook).ReportIfEmptySection(reportType.SummaryShowSameMaps,reportType.SummaryShowDifferentMaps,reportType.SummaryShowMissingMaps,reportType.SummaryShowExtraMaps)
 	} else {
 			// Lookup  content summary
 		set sequenceNumber=0
 		set tablename=""
			for {
				set tablename=$O(^||ReportData(..#RPTTypeMapping,tablename))
				quit:tablename=""
				
				// Need to calculate content clines=0
				// 1 to 4
				kill count
				set count=0
				set clines=1 // the maximum number of sub-report lines required in any one cell for this row.
				set countEnv=""
				for {
					set countEnv=$O(^||ReportData(..#RPTTypeMapping,tablename,"s",countEnv))
					quit:countEnv=""  // Each subtype item prints a line
					
					set countNs=""
					for {
						set countNs=$O(^||ReportData(..#RPTTypeMapping,tablename,"s",countEnv,countNs),+1,result)
						quit:countNs=""
						
						continue:result<1
						
						if '$Data(count(result)) {
							set count=count+1
							set count(result)=1	
						}
					}
				}

				// If any of the comapre environments have differences then display row over 4 lines for counts
				// Else display a single line for summary information
				set:$Data(count(..#RPTDifferent)) clines=4
				
				W !,"<Row ss:AutoFitHeight=""0"" ss:Height=""",##class(ompare.Report.ExportExcelWorkbook).CapLineHeight((clines)*$PARAMETER("ompare.Report.ExportExcelWorkbook","LineHeight")),""">"
				W !,"<Cell><Data ss:Type=""String"">",$Increment(sequenceNumber),"</Data></Cell>"  //seq
				W !,"<Cell><Data ss:Type=""String"">",..XMLO(tablename),"</Data></Cell>"
				
				set toNs=$O(^||ReportData(..#RPTTypeMapping,tablename,"s",definition.FromEnvironment,""),+1,result)
				if toNs="" {
					W !,"<Cell><Data ss:Type=""String""> - </Data></Cell>"
				} else {
					W !,"<Cell><Data ss:Type=""String"">",..XMLO($Case(result,..#RPTSame:"Same",..#RPTDifferent:"Different",..#RPTMissing:"Missing",..#RPTExtra:"Extra",:" - ")),"</Data></Cell>"
				}
				
				set env="",key=""
				set fromNs=definition.FromEnvironmentNameSpace()
  				for {
					set env=definition.Environments.GetNext(.key)
					quit:key=""
					continue:'$IsObject(env)
					continue:definition.FromEnvironment=env.Name
				
					set toNs=$O(^||ReportData(..#RPTTypeMapping,tablename,"s",env.Name,""),+1,result)
					if toNs="" {
						W !,"<Cell><Data ss:Type=""String""> - </Data></Cell>"
					} else {
						
						if result=..#RPTExtra {
							W !,"<Cell><Data ss:Type=""String"">Extra Map</Data></Cell>"
						} elseif result=..#RPTMissing {
							W !,"<Cell><Data ss:Type=""String"">Missing Map</Data></Cell>"
						} elseif result=..#RPTSame {
							W !,"<Cell><Data ss:Type=""String"">Map Identical</Data></Cell>"
						} else {
							set (missing,extra,different,same)=0
							// Different content - provide details.
							set fromDate=$P($G(^||ReportData("Meta","From")),"^",2)
							//set fromNs=$O(definition.Environments(definition.FromEnvironment,""))
							if fromNs'="" {
								set toDate=+$G(^||ReportData("Meta","To",env))
								set (fromSignature,toSignature)=""
								set:fromSignature="" fromSignature=$G(^ompare("Data",definition.FromEnvironment,fromNs,..#RPTTypeMapping,tablename))
								set:toSignature="" toSignature=$G(^ompare("Data",env.Name,toNs,..#RPTTypeMapping,tablename))
								
								if fromSignature'="",toSignature'="" {
									Do definition.DiffSignatureByNVP(fromSignature,toSignature,": ",.same,.missing,.different,.extra)	
						  		}
							}
						  
							// Style to wrap text
							W "<Cell ss:StyleID=""s67""><Data ss:Type=""String"">"
							set first=1
								//if same {
									set first=0
									Write ..XMLO(" * same map="_same)
								//}
								//if missing {
									write:'first ..#eol
									set first=0
									Write ..XMLO(" * missing map="_missing)
								//}
								//if extra {
									write:'first ..#eol
									set first=0
									Write ..XMLO(" * extra map="_extra)
								//}
								//if different {
									write:'first ..#eol
									set first=0
									Write ..XMLO(" * different map="_different)
								//}
						
							Write "</Data></Cell>"
						}
					}
				}
				
				W !,"</Row>"
			}
 	}
}

Storage Default
{
<Data name="MappingDefaultData">
<Subscript>"Mapping"</Subscript>
<Value name="1">
<Value>SummaryShowSameMaps</Value>
</Value>
<Value name="2">
<Value>SummaryShowDifferentMaps</Value>
</Value>
<Value name="3">
<Value>SummaryShowMissingMaps</Value>
</Value>
<Value name="4">
<Value>SummaryShowExtraMaps</Value>
</Value>
<Value name="5">
<Value>DetailShowSameMapsGlobal</Value>
</Value>
<Value name="6">
<Value>DetailShowDifferentMapsGlobal</Value>
</Value>
<Value name="7">
<Value>DetailShowMissingMapsGlobal</Value>
</Value>
<Value name="8">
<Value>DetailShowExtraMapsGlobal</Value>
</Value>
<Value name="9">
<Value>DetailShowSameMapsRoutine</Value>
</Value>
<Value name="10">
<Value>DetailShowDifferentMapsRoutine</Value>
</Value>
<Value name="11">
<Value>DetailShowMissingMapsRoutine</Value>
</Value>
<Value name="12">
<Value>DetailShowExtraMapsRoutine</Value>
</Value>
<Value name="13">
<Value>DetailShowSameMapsPackage</Value>
</Value>
<Value name="14">
<Value>DetailShowDifferentMapsPackage</Value>
</Value>
<Value name="15">
<Value>DetailShowMissingMapsPackage</Value>
</Value>
<Value name="16">
<Value>DetailShowExtraMapsPackage</Value>
</Value>
</Data>
<DefaultData>MappingDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}

