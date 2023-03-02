//This class serves as a container for the usernames allowed to be System Admins
public with sharing class SystemAdminsAllowed {
    public static String TEST_ADMIN_USERNAME = 'testing-xhgjfjehfhghfjdkdjh-admin@cloud.coinbase.testonly.com';

    public static Set<String> ALLOWED_SYSTEM_ADMINS = new Set<String>{
        'ashraf.abu-akeel@cloud.coinbae.com',
        'yatish.tandon@cloud.coinbase.com',
        'matt.beuttenmuller@cloud.coinbase.com',
        'jason.dodds@cloud.coinbase.com',
        'saurabh.sood@cloud.coinbase.com',
        'ankit.agarwal@cloud.coinbase.com',
        'megan.schrupp@cloud.coinbase.com',
        'peter.ogilvie@cloud.coinbase.com',
        'marshall.cho@cloud.coinbase.com',
        'alex.takacs@cloud.coinbase.com',
        'nevil.jain@cloud.coinbase.com',
        'sumit.gupta@cloud.coinbase.com',
        'goutham.juluru@cloud.coinbase.com',
        TEST_ADMIN_USERNAME
    };
}
