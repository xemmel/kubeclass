// See https://aka.ms/new-console-template for more information

int sleep = 3000;

string? sleepString = Environment.GetEnvironmentVariable("x_delay");
if (!string.IsNullOrEmpty(sleepString))
{
    sleep = int.Parse(sleepString);
}

Console.WriteLine("Hello, World!");

await Task.Delay(sleep);

Console.WriteLine("Finished...Hello, World");
