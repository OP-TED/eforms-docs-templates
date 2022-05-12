== ${notice_type_details.noticeId}

<#list notice_type_details.ruleTypes as ruleType>
=== ${ruleType.type!"-"}
[cols="<2,<7,>1"]
|====
h| Field h|Details h|Severity 
<#list ruleType.rules as rule>
h|<#if rule.fieldId?has_content!false>`${rule.fieldId}`</#if>
|<#if rule.pattern?has_content!false>
<#outputformat "RTF">Pattern: `${rule.pattern.id} ${rule.pattern.value}`</#outputformat>
</#if>
<#if rule.interval?has_content!false>Interval: `${rule.interval.id} ${rule.interval.lowerValue}-${rule.interval.higherValue}`</#if>
<#if rule.codeListId?has_content!false>Codelist: `${rule.codeListId}`</#if>
Condition: `${(rule.condition?has_content!false)?then(rule.condition.description, "ALWAYS")}`
|<#if rule.severity?has_content!false>${rule.severity}</#if>
</#list>
|====

</#list>
