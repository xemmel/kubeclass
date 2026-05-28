namespace SoapFault.Api.SOAP;


public class ServiceContract : IServiceContract
{
    public string Process(string input)
    {
        if (input.ToLower().Equals("error"))
        {
            throw new ApplicationException("Please do not enter 'error' enter something else");
        }
        return $"input: {input}";
    }
}