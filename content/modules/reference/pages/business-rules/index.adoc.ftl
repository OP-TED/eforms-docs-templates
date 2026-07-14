= Business Rules
The following Business Rules are included in eForms SDK {page-component-version}.

<#if notice_sub_types?has_content>
== Rules applicable to specific notice sub-types
Click on one of the notice sub-types listed below to see the business rules that apply to it:

${notice_sub_types?map(nst -> "xref:business-rules/notice-subtype-" + nst.noticeId + ".adoc[`" + nst.noticeId + "` ]")?join(", ")}
</#if>

<#if rules_without_notice_sub_type?has_content>
== Rules applicable to every notice sub-type
The following rules apply to every notice (grouped by type of rule):

<#list rules_without_notice_sub_type as ruleType>
=== `${ruleType.type!"-"}`
[cols="<4,4,<6,>1", role="fixed-layout"]
|====
h| Business Rule h| Field h|Details h|Severity
<#list ruleType.rules as rule>
h|<#if rule.id?has_content!false>`${rule.id}`</#if>
h|<#if rule.fieldId?has_content!false>`${rule.fieldId}`</#if>
a|<#if rule.pattern?has_content!false>
.RegEx pattern
[source, RegEx, subs="none"]
----
${rule.pattern.value?replace("|", "\\|")}
----
</#if>
<#if rule.interval?has_content!false>
*Interval*: `${rule.interval.lowerValue} - ${rule.interval.higherValue}`
</#if>
<#if rule.codeListId?has_content!false>
Value must be one of the codes in xref:code-lists/${rule.codeListId}.adoc[`${rule.codeListId}`] codelist.

</#if>
<#if ruleType.type == "mandatory" || ruleType.type == "allowed" || ruleType.type == "forbidden">
<#assign word = ruleType.type>
<#else>
<#assign word = "applies">
</#if> 
<#if rule.expression?has_content!false>
${rule.expression.description?cap_first!""}.

<#-- TEDEFO-4238: an EFX expression can contain '|' (e.g. a regex literal like
     '(T|t)'). '|' is the AsciiDoc table cell separator, so an unescaped pipe
     breaks this table; it must be escaped to '\|' via ?replace.
     The parentheses around (expressionEfx!"") are REQUIRED: FreeMarker's ?builtin
     binds tighter than the ! default operator, so 'expressionEfx!""?replace(...)'
     parses as 'expressionEfx ! ("" ?replace(...))' and emits non-empty values
     UNESCAPED. Keep the parentheses. -->
.Co-constraint in EFX
[source, EFX]
----
${(rule.expression.expressionEfx!"")?replace("|", "\\|")}
----
</#if>
<#if rule.condition?has_content!false>
<#if rule.condition.expressionEfx == "NEVER" || rule.condition.expressionEfx == "FALSE">
*Never ${word}* in every notice sub-type.
<#elseif rule.condition.expressionEfx == "ALWAYS" || rule.condition.expressionEfx == "TRUE">
*Always ${word}* in every notice sub-type.
<#else>
*${word?cap_first} if* ${rule.condition.description}.

<#-- TEDEFO-4238: escape '|' to '\|' so pipes in the EFX don't break the AsciiDoc table. -->
.Condition in EFX
[source, EFX]
----
${rule.condition.expressionEfx?replace("|", "\\|")}
----
</#if>
<#else>
*Always ${word}* in every notice sub-type.
</#if>
|<#if rule.severity?has_content!false>`${rule.severity}`<#else>`-`</#if>
</#list>
|====
</#list>
</#if>
