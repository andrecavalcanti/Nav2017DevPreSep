pageextension 50105 "ControlStabilityPage" extends "Item Card"
{
    layout
    {
        // Add changes to page layout here
        addlast(InventoryGrp)
        {
            field("Control Sample Qty";"Control Sample Qty")
            {

            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }
    
    var
        myInt : Integer;
}