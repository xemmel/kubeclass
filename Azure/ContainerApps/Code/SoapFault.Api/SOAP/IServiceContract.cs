using System.ServiceModel;

namespace SoapFault.Api.SOAP;

[ServiceContract]
public interface IServiceContract
{
     [OperationContract]
     string Process(string input);
}