public class Result {
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
    public boolean SearchResult{get;set;}
    public list<Result> res{get;set;}
    public list<Result> GradeSearch{get;set;}
    public boolean SRD{get;set;}
    public boolean searchgrade{get;set;}
    public string selectgrade{get;set;}
   
    public Result()
    {
         res = new list<Result>();
        Totalmarks = 500;
        NewResult = true;
        ResultInput = false;
        ResultOutput = false;
        DisplayResult = false;
        SearchResult = false;
    }
    
    public void NewResult()
    {
        NewResult = false;
        ResultInput = true;
        ResultOutput = false;
        DisplayResult = false;
        SearchResult = false;
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
        SearchResult = false;
    }
    public void SRD()
    {
        NewResult = false;
        ResultInput = false;
        ResultOutput = false;
        DisplayResult = false;
        SearchResult = true;
    }
    public void Add()
    {
        NewResult = false;
        ResultInput = false;
        ResultOutput = false;
        DisplayResult = true;
        SearchResult = false;
        Result disp = new Result();
        disp.name = Name;
        disp.HtNo = HtNo;
        disp.marksSecured = marksSecured;
        disp.Totalmarks = Totalmarks;
        disp.percent = percent;
        disp.grade = grade;
        res.add(disp);
        count = res.size();
        Name = null;
        Htno = null;
        marksSecured = null;  
    }
    public void searchgrade()
    {
        NewResult = false;
        ResultInput = false;
        ResultOutput = false;
        DisplayResult = false;
        SearchResult = true;
        SRD = true;
        GradeSearch = new List<Result>();
        for(result rest : res)
        {
            if(rest.grade == selectgrade)
            {
                gradesearch.add(rest);
            }
        }
    }
}