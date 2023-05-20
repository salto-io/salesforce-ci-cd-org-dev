<aura:application description="LookupApp" extends="force:slds">

    <!-- with Filter -->
<!--    <c:Lookup fieldLabel="Contact" objectAPIName="Contact"
              subHeadingFieldsAPI="Email,Phone"
              placeholder="Search Contact"
              filter="AccountId='001200000047KEdAAM'"/>    -->

    <!-- without Filter -->
    <c:Lookup fieldLabel="Contact" objectAPIName="Contact"
              subHeadingFieldsAPI="Email,Phone"
              placeholder="Search Contact"/>

</aura:application>