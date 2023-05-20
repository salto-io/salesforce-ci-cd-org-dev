public class CustomerCalculator {
Public integer firstNumber {get;set;}
    Public integer secondNumber {get;set;}
    Public integer result {get;set;}
    Public void Addition()
    {
        result = firstNumber + secondNumber;
    } 
    Public void Subtraction()
    {
        result = firstNumber -  secondNumber;
    }
    Public void Multiplication()
    {
        result = firstNumber * secondNumber;
    } 
    public void Division()
    {
        if(firstNumber != 0 && secondNumber == 0)
        {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Confirm, 'Division Operation Cannot be perfomed.'));           
        }
        else
        {
            result = firstNumber / secondNumber;
        }
    }
}