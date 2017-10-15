tableextension 50105 "Item Table Extension" extends "Item"
{
    fields
    {
        // Add changes to table fields here
        field(50105;"Control Sample Qty";Decimal)
        {
            Editable = false;
        }
    }
    
    var
        myInt : Integer;
}