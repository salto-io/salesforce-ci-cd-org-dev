public class Results {
	public string HtNo{get;set;}
    public string name{get;set;}
    public integer Totalmarks{get;set;}
    public integer marksSecured{get;set;}
    public double percent{get;set;}
    public String grade{get;set;}
    public integer count{get;set;}
    public boolean NewResult{get;set;}
    public boolean ResultInput{get;set;}
    public boolean ResultOutput{get;set;}
    public boolean DisplayResult{get;set;}
    public boolean DisplaySearch{get;set;}
    public list<Results> mark{get;set;}
    public list<Results> Searchgrade{get;set;}
    public boolean Searchresult{get;set;}
    public boolean search{get;set;}
    public string selectvalue{get;set;}
    
    public Results()
    {
        mark = new list<Results>();
        Totalmarks = 500;
        NewResult = true;
        ResultInput = false;
        ResultOutput = false;
        DisplayResult = false;
        DisplaySearch = false;
    }
    public void NewResult()
    {
        NewResult = false;
        ResultInput = true;
        ResultOutput = false;
        DisplayResult = false;
        DisplaySearch = false;
    }    
    public void save()
    {
        percent = (marksSecured*100)/Totalmarks;
        if(percent >= 85)
        {
         grade = 'A+';   
        }
        if(percent < 85 && percent >= 80)
        {
            grade = 'A';
        }
        if(percent < 80 && percent >= 75)
        {
            grade = 'B';
        }
        if(percent < 75 && percent >= 70)
        {
            grade = 'C';
        }
        if(percent < 70 && percent >= 65)
        {
            grade = 'D';
        }
        if(percent < 65)
        {
            grade = 'Fail';
        }
        NewResult = false;
        ResultInput = false;
        ResultOutput = true;
        DisplayResult = false;
        DisplaySearch = false;
    }
    public void Searchresult()
    {
        NewResult = false;
        ResultInput = false;
        ResultOutput = false;
        DisplayResult = false;
        DisplaySearch = true;
    }
    public void add()
    {
        NewResult = false;
        ResultInput = false;
        ResultOutput = false;
        DisplayResult = true;
        DisplaySearch = false;
        Results display = new Results();
        display.name = Name;
        display.HtNo = HtNo;
        display.marksSecured = marksSecured;
        display.Totalmarks = Totalmarks;
        display.percent = percent;
        display.grade = grade;
        mark.add(display);
        count = mark.size();
        Name = null;
        Htno = null;
        marksSecured = null;  
    }
    public void search()
    {
        NewResult = false;
        ResultInput = false;
        ResultOutput = false;
        DisplayResult = false;
        DisplaySearch = false;
        Searchresult = true;
        
       Searchgrade = new list<Results>();
        for(Results ers : mark)
        {
            if(ers.grade == Selectvalue)
            {
                Searchgrade.add(ers);
            }
        }
    }
}