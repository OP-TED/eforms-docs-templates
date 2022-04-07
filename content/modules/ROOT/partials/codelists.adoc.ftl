[cols="1,1"]
|===
|Codelist ID |Codelist Values
<#list codelists as codeListId, codeValues>

|${codeListId}
|${codeValues?join(", ")}
</#list>
|===
