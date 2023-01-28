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
Class ompare.Report.Environment Extends %SerialObject
{

Property Name As %String;

Property Namespaces As list Of %String;

Method HasNamespace(namespace As %String)
{
	quit (..Namespaces.Find(namespace))>0
}

Method AddNamespace(namespace As %String)
{
	if '..HasNamespace(namespace) {
		do ..Namespaces.Insert(namespace)
	}
}

ClassMethod ToMD(def As ompare.Report.Definition)
{
	kill def.EnvironmentsMD
	set key=""
	for {
		set env=def.Environments.GetNext(.key)
		quit:key=""
		continue:'$IsObject(env)
		continue:env.Name=""
		
		set key2=""
		for {
			set ns=env.Namespaces.GetNext(.key2)
			quit:key2=""
			continue:ns=""
			set def.EnvironmentsMD(env.Name,ns)=1
		}
	}	
	quit
}

ClassMethod FromMD(def As ompare.Report.Definition)
{
	do def.Environments.Clear()
	set env=""
	for {
		set env=$O(def.EnvironmentsMD(env))
		quit:env=""
		set oEnv=..%New()
		set oEnv.Name=env
		set ns=""
		for {
			set ns=$O(def.EnvironmentsMD(env,ns))
			quit:ns=""
			do oEnv.Namespaces.Insert(ns)	
		}
		do def.Environments.Insert(oEnv)
	}
}

/*
ClassMethod ToArray(ByRef envlist As %Library.ListOfDataTypes, ByRef ary)
{
	set key=""
	for {
		set env=envlist.GetNext(.key)
		quit:key=""
		continue:'$IsObject(env)
		continue:env.Name=""
		
		set key2=""
		for {
			set ns=env.Namespaces.GetNext(.key2)
			quit:key2=""
			continue:ns=""
			set ary(env.Name,ns)=""
		}
	}	
	quit
}

ClassMethod FromArray(ByRef envlist As %Library.ListOfDataTypes, ByRef ary)
{
	do envlist.Clear()
	set env=""
	for {
		set env=$O(ary(env))
		quit:env=""
		set oEnv=..%New()
		set oEnv.Name=env
		set ns=""
		for {
			set ns=$O(ary(env,ns))
			quit:ns=""
			do oEnv.Namespaces.Insert(ns)	
		}
		do envlist.Insert(oEnv)
	}
}
*/
ClassMethod IsDefined(envlist As %Library.ListOfDataTypes, name, namespace = "")
{
	#dim env as Environment
	set key="",found=0
	for {
		set env=envlist.GetNext(.key)
		quit:key=""
		continue:'$IsObject(env)
		if env.Name=name,namespace="" {
			set found=1
			quit	
		}
		if namespace'="" {
			set found=env.HasNamespace(namespace)
		}
	}	
	quit found
}

Storage Default
{
<Data name="EnvironmentState">
<Value name="1">
<Value>Name</Value>
</Value>
<Value name="2">
<Value>Namespaces</Value>
</Value>
</Data>
<State>EnvironmentState</State>
<StreamLocation>^ompare.Report.EnvironmentS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}

