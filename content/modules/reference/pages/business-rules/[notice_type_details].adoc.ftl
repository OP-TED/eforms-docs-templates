= Business rules for notice sub-type `${notice_type_details.noticeId}`

<#list notice_type_details.ruleTypes?sort_by("type") as ruleType>
== `${ruleType.type!"-"}`
[cols="<3,<6,>1", role="fixedlayout"]
|====
h| Field h|Details h|Severity 
<#list ruleType.rules as rule>
h|<#if rule.fieldId?has_content!false>`${rule.fieldId}`</#if>
a|<#if rule.pattern?has_content!false>
.RegEx pattern
[source, RegEx, subs="none"]
----
${rule.pattern.value?replace("|", "\\|")}
----
</#if>
<#if rule.interval?has_content!false>Interval: `${rule.interval.lowerValue} - ${rule.interval.higherValue}`</#if>
<#if rule.codeListId?has_content!false>Codelist: `${rule.codeListId}`</#if>
<#if ruleType.type == "mandatory" || ruleType.type == "allowed" || ruleType.type == "forbidden">
<#assign word = ruleType.type>
<#else>
<#assign word = "applies">
</#if> 
<#if rule.condition?has_content!false>
<#if rule.condition.expressionEfx == "NEVER" || rule.condition.expressionEfx == "FALSE">
*Never ${word}* in notice sub-type ${notice_type_details.noticeId}.
<#elseif rule.condition.expressionEfx == "ALWAYS" || rule.condition.expressionEfx == "TRUE">
*Always ${word}* in notice sub-type ${notice_type_details.noticeId}.
<#else>
*${word?cap_first} if* ${rule.condition.description}.

.Condition in EFX
[source, EFX]
----
${rule.condition.expressionEfx}
----
</#if>
<#else>
*Always ${word}* in notice sub-type ${notice_type_details.noticeId}.
</#if>
|<#if rule.severity?has_content!false>`${rule.severity}`</#if>
</#list>
|====

</#list>