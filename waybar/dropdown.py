import waybar

class DropdownMenu(waybar.Module):
    def __init__(self):
        self.menu = [
            {"label": "Option 1", "action": self.option_1},
            {"label": "Option 2", "action": self.option_2},
            {"label": "Option 3", "action": self.option_3},
        ]

    def render(self):
        menu_items = ""
        for item in self.menu:
            menu_items += f'<div class="dropdown-menu-item" onclick="{item["action"]}">{item["label"]}</div>'

        return f'<div class="dropdown-menu">{menu_items}</div>'

    def option_1(self):
        print("Option 1 selected")

    def option_2(self):
        print("Option 2 selected")

    def option_3(self):
        print("Option 3 selected")

waybar.register("dropdown-menu", DropdownMenu)