public class Company {
	public String companyName;
    public String ceo;
    public Integer employeecount;
    public Long revenue;
    
    
    //List of customer
    //
    private List<Client> customers = new List<Client>();
    
    public void addNewCustomer(String clientName,String email,String website,Long Phone){
        Client customer=new Client(clientName,email,website,Phone);
        customers.add(customer);
    }
    
     public void getAllCustomers(){
        for (Client customer : customers)
        {
            system.debug('customer name' +customer.clientName + 'Email ' + customer.email + 'website' +customer.website + ' phone' +customer.phone);
        }
    }
    
    //private inner class
    private class Client {
        public String clientName;
    public String email;
    public String website;
    public Long phone;
    
    Client (String clientName,String email,String website,Long Phone)
    {
        this.clientName=clientName;
        this.email=email;
        this.website=website;
        this.Phone=Phone;
        
    }
    
    }
    
    
}