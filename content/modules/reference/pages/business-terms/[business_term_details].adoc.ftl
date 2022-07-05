= `${business_term_details.id}`: ${business_term_details.description!""}
[horizontal]
<#if business_term_details.type?has_content!false>
Type:: ${business_term_details.type}
</#if>
<#if business_term_details.fields?has_content!false>
== Fields
[horizontal]
  <#list business_term_details.fields as field>
  `${field.id}`:: ${field.description}
  </#list>
</#if>
