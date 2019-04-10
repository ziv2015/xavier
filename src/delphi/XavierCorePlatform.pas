{
  MIT License

  Copyright (c) 2017-2019 Marcos Douglas B. Santos

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
}
unit XavierCorePlatform;

{$i Xavier.inc}

interface

uses
  Classes, 
  SysUtils,
  xmlDoc, 
  xmlIntf,
  xmlDom,
  SynCommons,
  JamesDataBase,
  JamesDataCore,
  XavierBase,
  XavierCore,
  XavierAdapters;

type
  TXMLAttribute = class(TInterfacedObject, IXMLAttribute)
  private
    fNode: IXMLDomNode;                                 
  public
    constructor Create(ANode: IXMLDomNode);
    function Ref: IXMLAttribute;
    function Name: TXavierString;
    function Text: TXavierString; overload;
    function Text(const aText: TXavierString): IXMLAttribute; overload;
    function Node: IXMLNode;
  end;

  TXMLAttributes = class(TInterfacedObject, IXMLAttributes)
  private
    fNode: IXMLDomNode;
  public
    constructor Create(aNode: IXMLDomNode);
    function Ref: IXMLAttributes;
    function Add(const aName, aText: TXavierString): IXMLAttribute;
    function Item(aIndex: Integer): IXMLAttribute; overload;
    function Item(const aName: TXavierString): IXMLAttribute; overload;
    function Count: Integer;
  end;

  TXMLNode = class(TInterfacedObject, IXMLNode)
  private
    fNode: IXMLDomNode;
  public
    constructor Create(aNode: IXMLDomNode);
    function Ref: IXMLNode;
    function Name: TXavierString;
    function Text: TXavierString; overload;
    function Text(const aText: TXavierString): IXMLNode; overload;
    function Text(const aText: string): IXMLNode; overload;
    function Attrs: IXMLAttributes;
    function Add(const aName: TXavierString): IXMLNode;
    function Childs: IXMLNodes;
    function Parent: IXMLNode;
  end;

  TXMLChilds = class(TInterfacedObject, IXMLNodes)
  private
    fNode: IXMLDomNode;
  public
    constructor Create(aNode: IXMLDomNode);
    function Ref: IXMLNodes;
    function Item(aIndex: Integer): IXMLNode; overload;
    function Item(const aName: TXavierString): IXMLNode; overload;
    function Count: Integer;
  end;

  TXMLPack = class(TInterfacedObject, IXMLPack)
  private
    fDocument: IXMLDOMDocument3;
  public
    constructor Create(aStream: TStream); reintroduce; overload;
    constructor Create(const aRootName: RawUTF8); overload;
    function Nodes(const XPath: TXavierString): IXMLNodes;
    function Node(const XPath: TXavierString): IXMLNode; overload;
    function Node(const XPath: TXavierString; const aDefault: IXMLNode): IXMLNode; overload;
    function Stream: IDataStream;
  end;

implementation

{ TXMLAttribute }

constructor TXMLAttribute.Create(ANode: IXMLDomNode);
begin
  inherited Create;
  fNode := ANode;
end;

function TXMLAttribute.Ref: IXMLAttribute;
begin
  result := self;
end;

function TXMLAttribute.Name: TXavierString;
begin
  result := fNode.NodeName;
end;

function TXMLAttribute.Text: TXavierString;
begin
  result := fNode.NodeValue;
end;

function TXMLAttribute.Text(const aText: TXavierString): IXMLAttribute;
begin
  result := self;
  fNode.NodeValue := aText;
end;

function TXMLAttribute.Node: IXMLNode;
begin
  result := TXMLNode.Create(fNode.ParentNode);
end;

{ TXMLAttributes }

constructor TXMLAttributes.Create(aNode: IXMLDomNode);
begin
  inherited Create;
  fNode := aNode;
end;

function TXMLAttributes.Ref: IXMLAttributes;
begin
  result := self;
end;

function TXMLAttributes.Add(const aName, aText: TXavierString): IXMLAttribute;
begin
  // todo
end;

function TXMLAttributes.Item(aIndex: Integer): IXMLAttribute;
var
  n: IXMLDomNode;
begin
  n := fNode.Attributes.Item[aIndex];
  if not Assigned(n) then
    raise EXMLError.CreateFmt('Node not found on index %d.', [aIndex]);
  result := TXMLAttribute.Create(n);
end;

function TXMLAttributes.Item(const aName: TXavierString): IXMLAttribute;
var
  n: IXMLDomNode;
begin
  n := fNode.Attributes.GetNamedItem(aName);
  if not Assigned(n) then
    raise EXMLError.CreateFmt('Node "%s" not found.', [aName]);
  result := TXMLAttribute.Create(n);
end;

function TXMLAttributes.Count: Integer;
begin
  result := fNode.Attributes.Length;
end;

{ TXMLNode }

constructor TXMLNode.Create(aNode: IXMLDomNode);
begin
  inherited Create;
  fNode := aNode;
end;

function TXMLNode.Ref: IXMLNode;
begin
  result := self;
end;

function TXMLNode.Name: TXavierString;
begin
  result := fNode.NodeName;
end;

function TXMLNode.Text: TXavierString;
begin
  result := fNode.nodeValue;
end;

function TXMLNode.Text(const aText: TXavierString): IXMLNode;
begin
  result := self;
  fNode.NodeValue := aText;
end;

function TXMLNode.Text(const aText: string): IXMLNode;
begin
  result := self;
  Text(TXavierString(aText));
end;

function TXMLNode.Attrs: IXMLAttributes;
begin
  result := TXMLAttributes.Create(fNode);
end;

function TXMLNode.Add(const aName: TXavierString): IXMLNode;
begin
  result := TXMLNode.Create(
    fNode.AppendChild(
      fNode.OwnerDocument.CreateElement(TXavierString(aName))
    )
  );
end;

function TXMLNode.Childs: IXMLNodes;
begin
  result := TXMLChilds.Create(fNode);
end;

function TXMLNode.Parent: IXMLNode;
begin
  result := TXMLNode.Create(fNode.ParentNode);
end;

{ TXMLChilds }

constructor TXMLChilds.Create(aNode: IXMLDomNode);
begin
  inherited Create;
  fNode := ANode;
end;

function TXMLChilds.Ref: IXMLNodes;
begin
  result := self;
end;

function TXMLChilds.Item(aIndex: Integer): IXMLNode;
begin
  result := TXMLNode.Create(fNode.ChildNodes.Item[aIndex]);
end;

function TXMLChilds.Item(const aName: TXavierString): IXMLNode;
begin
  // todo
end;

function TXMLChilds.Count: Integer;
begin
  result := fNode.ChildNodes.Length;
end;

{ TXMLPack }

constructor TXMLPack.Create(aStream: TStream);
var
  sa: TDataStreamAdapter;
begin
  inherited Create;
  aStream.Position := 0;
  sa.Init(TDataStream.Create(aStream));
  fDocument := MSXML2_TLB.CoDOMDocument60.Create;
  fDocument.load(sa.AsOleVariant);
end;

constructor TXMLPack.Create(const aRootName: RawUTF8);
var
  a: TXMLRootNameAdapter;
  m: TStream;
begin
  m := TMemoryStream.Create;
  try
    a.Init(aRootName);
    a.ToStream(m);
    Create(m);
  finally
    m.Free;
  end;
end;

function TXMLPack.Nodes(const XPath: TXavierString): IXMLNodes;
begin
  raise EXMLError.Create('Not implemented yet');
end;

function TXMLPack.Node(const XPath: TXavierString): IXMLNode;
var
  l: IXMLNodes;
begin
  l := Nodes(XPath);
  if l.Count = 0 then
    raise EXMLError.Create('Node not found.');
  result := l.Item(0);
end;

function TXMLPack.Node(const XPath: TXavierString;
  const aDefault: IXMLNode): IXMLNode;
var
  l: IXMLNodes;
begin
  l := Nodes(XPath);
  if l.Count = 0 then
    result := aDefault
  else
    result := l.Item(0);
end;

function TXMLPack.Stream: IDataStream;
var
  m: TStream;
begin
  m := TMemoryStream.Create;
  try
    fDocument.SaveToStream(m);
    result := TDataStream.Create(m);
  finally
    m.Free;
  end;
end;

end.

