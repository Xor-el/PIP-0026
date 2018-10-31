unit PASCPaymentURITests;

{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF FPC}

interface

uses
  SysUtils,
{$IFDEF FPC}
  fpcunit,
  testregistry,
{$ELSE}
  TestFramework,
{$ENDIF FPC}
  UPASCPaymentURI;

type

  TPASCPaymentURITestCase = class abstract(TTestCase)

  end;

type

  TRFC3986URIToolsTestCase = class abstract(TPASCPaymentURITestCase)

  end;

type

  /// <summary>
  /// Test Vectors were gotten from <see href="https://www.urlencoder.org/">
  /// URLEncoder</see>
  /// </summary>
  TTestRFC3986URITools = class(TRFC3986URIToolsTestCase)

  private
    FExpectedString, FActualString: String;
    FPlain, FEncodedUTF8: TPASCPaymentURIGenericArray<String>;
    FEncodingUTF8: TEncoding;

  protected
    procedure SetUp; override;
    procedure TearDown; override;

  published
    procedure TestEncodeUTF8;
    procedure TestDecodeUTF8;

  end;

type

  TPASCBuilderTestCase = class abstract(TPASCPaymentURITestCase)

  end;

type
  TTestPASCBuilder = class(TPASCBuilderTestCase)

  private
    FPASCPaymentURI: IPASCPaymentURI;
    FExpectedString, FActualString: String;

  protected
    procedure SetUp; override;
    procedure TearDown; override;

  published
    procedure TestCompleteBuilder;
    procedure TestBuilderAmountAsZero;
    procedure TestBuilderWithVerySmallAmount;
    procedure TestBuilderWithVeryTinyAmount;
    procedure TestBuilderWithOnlyAccount;
    procedure TestBuilderWithOnlyAccountAndAmount;
    procedure TestBuilderWithOnlyAccountAndLabel;
    procedure TestBuilderWithOnlyAccountAndMessage;
    procedure TestNegativeAmountShouldRaise;
    procedure TestEmptyAccountShouldRaise;
    procedure TestInvalidAccountShouldRaise;
    procedure TestParseInvalidURIs;
    procedure TestParseInvalidURIsShouldRaise;
    procedure TestParseForAccount;
    procedure TestParseForAccountWithAmount;
    procedure TestParseForAccountWithAmountandLabel;
    procedure TestParseForAccountWithAmountLabelandMessage;

  end;

implementation

{ TTestRFC3986URITools }

procedure TTestRFC3986URITools.SetUp;
begin
  inherited;
  FPlain := TPASCPaymentURIGenericArray<String>.Create('@', 'ü', ' -_.~', '% ',
    '%Format<>', 'The string ü@foo-bar', 'https://www.urlencoder.org/',
    '!	*	''	(	)	;	:	@	&	=	+	$	,	/	?	#	[	]', '漢字汉字',
    'б, в, г, д, ж, з, к, л, м, н, п, р, с, т, ф, х, ц, ч, ш, щ, а, э, ы, у, о, я, е, ё, ю, и.');
  FEncodedUTF8 := TPASCPaymentURIGenericArray<String>.Create('%40', '%C3%BC',
    '%20-_.~', '%25%20', '%25Format%3C%3E', 'The%20string%20%C3%BC%40foo-bar',
    'https%3A%2F%2Fwww.urlencoder.org%2F',
    '%21%09%2A%09%27%09%28%09%29%09%3B%09%3A%09%40%09%26%09%3D%09%2B%09%24%09%2C%09%2F%09%3F%09%23%09%5B%09%5D',
    '%E6%BC%A2%E5%AD%97%E6%B1%89%E5%AD%97',
    '%D0%B1%2C%20%D0%B2%2C%20%D0%B3%2C%20%D0%B4%2C%20%D0%B6%2C%20%D0%B7%2C%20%D0%BA%2C%20%D0%BB%2C%20%D0%BC'
    + '%2C%20%D0%BD%2C%20%D0%BF%2C%20%D1%80%2C%20%D1%81%2C%20%D1%82%2C%20%D1%84%2C%20%D1%85%2C%20%D1%86%2C%20'
    + '%D1%87%2C%20%D1%88%2C%20%D1%89%2C%20%D0%B0%2C%20%D1%8D%2C%20%D1%8B%2C%20%D1%83%2C%20%D0%BE%2C%20%D1%8F'
    + '%2C%20%D0%B5%2C%20%D1%91%2C%20%D1%8E%2C%20%D0%B8.');
  FEncodingUTF8 := TEncoding.UTF8;
end;

procedure TTestRFC3986URITools.TearDown;
begin
  FPlain := Nil;
  FEncodedUTF8 := Nil;
  inherited;
end;

procedure TTestRFC3986URITools.TestEncodeUTF8;
var
  LIdx: Int32;
  LStringToEncode: String;
begin
  for LIdx := System.Low(FPlain) to System.High(FPlain) do
  begin
    LStringToEncode := FPlain[LIdx];
    FExpectedString := FEncodedUTF8[LIdx];
    FActualString := TPASCPaymentURI.TRFC3986URITools.Encode(LStringToEncode,
      FEncodingUTF8);

    CheckEquals(FExpectedString, FActualString,
      Format('Expected [%s] from encoding [%s] but got [%s]',
      [FExpectedString, LStringToEncode, FActualString]));
  end;

end;

procedure TTestRFC3986URITools.TestDecodeUTF8;
var
  LIdx: Int32;
  LStringToDecode: String;
begin
  for LIdx := System.Low(FEncodedUTF8) to System.High(FEncodedUTF8) do
  begin
    LStringToDecode := FEncodedUTF8[LIdx];
    FExpectedString := FPlain[LIdx];
    FActualString := TPASCPaymentURI.TRFC3986URITools.Decode(LStringToDecode,
      FEncodingUTF8);

    CheckEquals(FExpectedString, FActualString,
      Format('Expected [%s] from decoding [%s] but got [%s]',
      [FExpectedString, LStringToDecode, FActualString]));
  end;

end;

{ TTestPASCBuilder }

procedure TTestPASCBuilder.SetUp;
begin
  inherited;

end;

procedure TTestPASCBuilder.TearDown;
begin
  FPASCPaymentURI := Nil;
  inherited;
end;

procedure TTestPASCBuilder.TestBuilderWithOnlyAccount;
var
  LAmount: Double;
begin
  LAmount := 0;
  FExpectedString := 'pasc:0-10';

  FPASCPaymentURI := TPASCPaymentURI.TPASCBuilder.Builder()
    .AddAccount('0-10').Build();

  CheckEquals(FPASCPaymentURI.Account, '0-10');
  CheckEquals(FPASCPaymentURI.Amount, LAmount);
  CheckEquals(FPASCPaymentURI.&Label, '');
  CheckEquals(FPASCPaymentURI.Message, '');

  FActualString := FPASCPaymentURI.GetURI();
  CheckEquals(FExpectedString, FActualString,
    Format('Expected [%s] but got [%s]', [FExpectedString, FActualString]));

end;

procedure TTestPASCBuilder.TestBuilderWithOnlyAccountAndAmount;
var
  LAmount: Double;
begin
  LAmount := 50.52;
  FExpectedString := 'pasc:0-10?amount=50.5200';

  FPASCPaymentURI := TPASCPaymentURI.TPASCBuilder.Builder().AddAccount('0-10')
    .AddAmount(LAmount).Build();

  CheckEquals(FPASCPaymentURI.Account, '0-10');
  CheckEquals(FPASCPaymentURI.Amount, LAmount);
  CheckEquals(FPASCPaymentURI.&Label, '');
  CheckEquals(FPASCPaymentURI.Message, '');

  FActualString := FPASCPaymentURI.GetURI();
  CheckEquals(FExpectedString, FActualString,
    Format('Expected [%s] but got [%s]', [FExpectedString, FActualString]));

end;

procedure TTestPASCBuilder.TestBuilderAmountAsZero;
var
  LAmount: Double;
begin
  LAmount := 0;
  FExpectedString :=
    'pasc:0-10?label=PascalCoin-Dev&message=Freewill%20Donation';

  FPASCPaymentURI := TPASCPaymentURI.TPASCBuilder.Builder().AddAccount('0-10')
    .AddAmount(LAmount).AddLabel('PascalCoin-Dev')
    .AddMessage('Freewill Donation').Build();

  CheckEquals(FPASCPaymentURI.Account, '0-10');
  CheckEquals(FPASCPaymentURI.Amount, LAmount);
  CheckEquals(FPASCPaymentURI.&Label, 'PascalCoin-Dev');
  CheckEquals(FPASCPaymentURI.Message, 'Freewill Donation');

  FActualString := FPASCPaymentURI.GetURI();
  CheckEquals(FExpectedString, FActualString,
    Format('Expected [%s] but got [%s]', [FExpectedString, FActualString]));

end;

procedure TTestPASCBuilder.TestBuilderWithVerySmallAmount;
var
  LAmount: Double;
begin
  LAmount := 0.0001;
  FExpectedString :=
    'pasc:0-10?amount=0.0001&label=PascalCoin-Dev&message=Freewill%20Donation';

  FPASCPaymentURI := TPASCPaymentURI.TPASCBuilder.Builder().AddAccount('0-10')
    .AddAmount(LAmount).AddLabel('PascalCoin-Dev')
    .AddMessage('Freewill Donation').Build();

  CheckEquals(FPASCPaymentURI.Account, '0-10');
  CheckEquals(FPASCPaymentURI.Amount, LAmount);
  CheckEquals(FPASCPaymentURI.&Label, 'PascalCoin-Dev');
  CheckEquals(FPASCPaymentURI.Message, 'Freewill Donation');

  FActualString := FPASCPaymentURI.GetURI();
  CheckEquals(FExpectedString, FActualString,
    Format('Expected [%s] but got [%s]', [FExpectedString, FActualString]));

end;

procedure TTestPASCBuilder.TestBuilderWithVeryTinyAmount;
var
  LAmount: Double;
begin
  LAmount := 0.00009;
  FExpectedString :=
    'pasc:0-10?label=PascalCoin-Dev&message=Freewill%20Donation';

  FPASCPaymentURI := TPASCPaymentURI.TPASCBuilder.Builder().AddAccount('0-10')
    .AddAmount(LAmount).AddLabel('PascalCoin-Dev')
    .AddMessage('Freewill Donation').Build();

  CheckEquals(FPASCPaymentURI.Account, '0-10');
  CheckEquals(FPASCPaymentURI.Amount, LAmount);
  CheckEquals(FPASCPaymentURI.&Label, 'PascalCoin-Dev');
  CheckEquals(FPASCPaymentURI.Message, 'Freewill Donation');

  FActualString := FPASCPaymentURI.GetURI();
  CheckEquals(FExpectedString, FActualString,
    Format('Expected [%s] but got [%s]', [FExpectedString, FActualString]));
end;

procedure TTestPASCBuilder.TestBuilderWithOnlyAccountAndLabel;
var
  LAmount: Double;
begin
  LAmount := 0;
  FExpectedString := 'pasc:0-10?label=PascalCoin-Dev';

  FPASCPaymentURI := TPASCPaymentURI.TPASCBuilder.Builder().AddAccount('0-10')
    .AddLabel('PascalCoin-Dev').Build();

  CheckEquals(FPASCPaymentURI.Account, '0-10');
  CheckEquals(FPASCPaymentURI.Amount, LAmount);
  CheckEquals(FPASCPaymentURI.&Label, 'PascalCoin-Dev');
  CheckEquals(FPASCPaymentURI.Message, '');

  FActualString := FPASCPaymentURI.GetURI();
  CheckEquals(FExpectedString, FActualString,
    Format('Expected [%s] but got [%s]', [FExpectedString, FActualString]));

end;

procedure TTestPASCBuilder.TestBuilderWithOnlyAccountAndMessage;
var
  LAmount: Double;
begin
  LAmount := 0;
  FExpectedString := 'pasc:0-10?message=Freewill%20Donation';

  FPASCPaymentURI := TPASCPaymentURI.TPASCBuilder.Builder().AddAccount('0-10')
    .AddMessage('Freewill Donation').Build();

  CheckEquals(FPASCPaymentURI.Account, '0-10');
  CheckEquals(FPASCPaymentURI.Amount, LAmount);
  CheckEquals(FPASCPaymentURI.&Label, '');
  CheckEquals(FPASCPaymentURI.Message, 'Freewill Donation');

  FActualString := FPASCPaymentURI.GetURI();
  CheckEquals(FExpectedString, FActualString,
    Format('Expected [%s] but got [%s]', [FExpectedString, FActualString]));

end;

procedure TTestPASCBuilder.TestCompleteBuilder;
var
  LAmount: Double;
begin
  LAmount := 50.035;
  FExpectedString :=
    'pasc:0-10?amount=50.0350&label=PascalCoin-Dev&message=Freewill%20Donation';

  FPASCPaymentURI := TPASCPaymentURI.TPASCBuilder.Builder().AddAccount('0-10')
    .AddAmount(LAmount).AddLabel('PascalCoin-Dev')
    .AddMessage('Freewill Donation').Build();

  CheckEquals(FPASCPaymentURI.Account, '0-10');
  CheckEquals(FPASCPaymentURI.Amount, LAmount);
  CheckEquals(FPASCPaymentURI.&Label, 'PascalCoin-Dev');
  CheckEquals(FPASCPaymentURI.Message, 'Freewill Donation');

  FActualString := FPASCPaymentURI.GetURI();
  CheckEquals(FExpectedString, FActualString,
    Format('Expected [%s] but got [%s]', [FExpectedString, FActualString]));

end;

procedure TTestPASCBuilder.TestEmptyAccountShouldRaise;
var
  LAmount: Double;
begin
  LAmount := 0.5;

  try
    FPASCPaymentURI := TPASCPaymentURI.TPASCBuilder.Builder().AddAccount('')
      .AddAmount(LAmount).AddLabel('PascalCoin-Dev')
      .AddMessage('Freewill Donation').Build();
    Fail('Exception Expected');
  except
    // pass
  end;

end;

procedure TTestPASCBuilder.TestInvalidAccountShouldRaise;
var
  LAmount: Double;
begin
  LAmount := 2.48;

  try
    FPASCPaymentURI := TPASCPaymentURI.TPASCBuilder.Builder().AddAccount('0-11')
      .AddAmount(LAmount).AddLabel('PascalCoin-Dev')
      .AddMessage('Freewill Donation').Build();
    Fail('Exception Expected');
  except
    // pass
  end;

end;

procedure TTestPASCBuilder.TestNegativeAmountShouldRaise;
var
  LAmount: Double;
begin
  LAmount := -25.56;

  try
    FPASCPaymentURI := TPASCPaymentURI.TPASCBuilder.Builder().AddAccount('0-10')
      .AddAmount(LAmount).AddLabel('PascalCoin-Dev')
      .AddMessage('Freewill Donation').Build();
    Fail('Exception Expected');
  except
    // pass
  end;

end;

procedure TTestPASCBuilder.TestParseForAccount;
var
  LAmount: Double;
begin
  LAmount := 0;
  FPASCPaymentURI := TPASCPaymentURI.Parse('pasc:0-10');

  CheckEquals(FPASCPaymentURI.Account, '0-10');
  CheckEquals(FPASCPaymentURI.Amount, LAmount);
  CheckEquals(FPASCPaymentURI.&Label, '');
  CheckEquals(FPASCPaymentURI.Message, '');
end;

procedure TTestPASCBuilder.TestParseForAccountWithAmount;
var
  LAmount: Double;
begin
  LAmount := 20.3;
  FPASCPaymentURI := TPASCPaymentURI.Parse('pasc:0-10?amount=20.3');

  CheckEquals(FPASCPaymentURI.Account, '0-10');
  CheckEquals(FPASCPaymentURI.Amount, LAmount);
  CheckEquals(FPASCPaymentURI.&Label, '');
  CheckEquals(FPASCPaymentURI.Message, '');
end;

procedure TTestPASCBuilder.TestParseForAccountWithAmountandLabel;
var
  LAmount: Double;
begin
  LAmount := 50.532;
  FPASCPaymentURI := TPASCPaymentURI.Parse
    ('pasc:0-10?amount=50.532&label=PascalCoin-Dev');

  CheckEquals(FPASCPaymentURI.Account, '0-10');
  CheckEquals(FPASCPaymentURI.Amount, LAmount);
  CheckEquals(FPASCPaymentURI.&Label, 'PascalCoin-Dev');
  CheckEquals(FPASCPaymentURI.Message, '');
end;

procedure TTestPASCBuilder.TestParseForAccountWithAmountLabelandMessage;
var
  LAmount: Double;
begin
  LAmount := 50.532;
  FPASCPaymentURI := TPASCPaymentURI.Parse
    ('pasc:0-10?amount=50.532&label=PascalCoin-Dev&message=Freewill%20Donations');

  CheckEquals(FPASCPaymentURI.Account, '0-10');
  CheckEquals(FPASCPaymentURI.Amount, LAmount);
  CheckEquals(FPASCPaymentURI.&Label, 'PascalCoin-Dev');
  CheckEquals(FPASCPaymentURI.Message, 'Freewill Donations');
end;

procedure TTestPASCBuilder.TestParseInvalidURIs;
begin
  FPASCPaymentURI := TPASCPaymentURI.Parse
    ('pascX:0-10?somethingyoudontunderstand:=50');
  CheckNull(FPASCPaymentURI, 'Test 1 Failed');

  FPASCPaymentURI := TPASCPaymentURI.Parse
    ('pasc0-10?somethingyoudontunderstand:=50');
  CheckNull(FPASCPaymentURI, 'Test 2 Failed');

  FPASCPaymentURI := TPASCPaymentURI.Parse
    ('pasc:?somethingyoudontunderstand:=50');
  CheckNull(FPASCPaymentURI, 'Test 3 Failed');

  FPASCPaymentURI := TPASCPaymentURI.Parse('pasc:0-10?label');
  CheckNull(FPASCPaymentURI, 'Test 4 Failed');

  FPASCPaymentURI := TPASCPaymentURI.Parse('pasc');
  CheckNull(FPASCPaymentURI, 'Test 5 Failed');

  FPASCPaymentURI := TPASCPaymentURI.Parse('pasc:');
  CheckNull(FPASCPaymentURI, 'Test 6 Failed');

  FPASCPaymentURI := TPASCPaymentURI.Parse('pasc :');
  CheckNull(FPASCPaymentURI, 'Test 7 Failed');

  FPASCPaymentURI := TPASCPaymentURI.Parse('pasc : ');
  CheckNull(FPASCPaymentURI, 'Test 8 Failed');

  FPASCPaymentURI := TPASCPaymentURI.Parse('');
  CheckNull(FPASCPaymentURI, 'Test 9 Failed');

  FPASCPaymentURI := TPASCPaymentURI.Parse('     ');
  CheckNull(FPASCPaymentURI, 'Test 10 Failed');

  FPASCPaymentURI := TPASCPaymentURI.Parse('pasc:0-10?');
  CheckNull(FPASCPaymentURI, 'Test 11 Failed');

  FPASCPaymentURI := TPASCPaymentURI.Parse('pasc:0-10?label=&message');
  CheckNull(FPASCPaymentURI, 'Test 12 Failed');

  FPASCPaymentURI := TPASCPaymentURI.Parse('pasc:0-10?message');
  CheckNull(FPASCPaymentURI, 'Test 13 Failed');

  FPASCPaymentURI := TPASCPaymentURI.Parse('molina:0-10');
  CheckNull(FPASCPaymentURI, 'Test 14 Failed');

  FPASCPaymentURI := TPASCPaymentURI.Parse('0-10');
  CheckNull(FPASCPaymentURI, 'Test 15 Failed');

end;

procedure TTestPASCBuilder.TestParseInvalidURIsShouldRaise;
begin
  try
    FPASCPaymentURI := TPASCPaymentURI.Parse('pasc: ');
    Fail(Format('Test 1 Failed "%s"', ['Exception Expected']));
  except
    // reason, invalid account
  end;

  try
    FPASCPaymentURI := TPASCPaymentURI.Parse('pasc://0-10');
    Fail(Format('Test 2 Failed "%s"', ['Exception Expected']));
  except
    // reason, invalid account
  end;

  try
    FPASCPaymentURI := TPASCPaymentURI.Parse('pasc:0-10?amount=-0.0001');
    Fail(Format('Test 3 Failed "%s"', ['Exception Expected']));
  except
    // reason, negative amount
  end;

  try
    FPASCPaymentURI := TPASCPaymentURI.Parse('pasc:0-10?amount=two');
    Fail(Format('Test 4 Failed "%s"', ['Exception Expected']));
  except
    // reason, invalid amount
  end;

  try
    FPASCPaymentURI := TPASCPaymentURI.Parse('pasc:0-10?amount=NaN');
    Fail(Format('Test 5 Failed "%s"', ['Exception Expected']));
  except
    // reason, invalid amount
  end;

  try
    FPASCPaymentURI := TPASCPaymentURI.Parse('pasc:0-10?amount=Infinity');
    Fail(Format('Test 6 Failed "%s"', ['Exception Expected']));
  except
    // reason, invalid amount
  end;
end;

initialization

// Register any test cases with the test runner

{$IFDEF FPC}
  RegisterTest(TTestRFC3986URITools);
RegisterTest(TTestPASCBuilder);
{$ELSE}
  RegisterTest(TTestRFC3986URITools.Suite);
RegisterTest(TTestPASCBuilder.Suite);
{$ENDIF FPC}

end.
