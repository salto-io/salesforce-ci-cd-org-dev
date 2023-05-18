public class Friends {
//

final Integer oneslice=8;
final integer uptothree=7;
final integer greaterthan3=6;


public Integer getbill(Integer slices)
{
    Integer billtopay  =slices == 1 ?oneslice * slices : 
						(slices<=3 ? uptothree * slices :greaterthan3 * slices );
    
    		return billtopay;
}

}