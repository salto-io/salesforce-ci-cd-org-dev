@isTest
public class CC_test {
    public static testmethod void CustomerCalculator(){
        CustomerCalculator ccal = new CustomerCalculator();
        ccal.firstNumber = 45;
        ccal.secondNumber = 65;
        ccal.result = 110;
        ccal.Addition();
        ccal.Division();
        ccal.Multiplication();
        ccal.Subtraction();
    }
}