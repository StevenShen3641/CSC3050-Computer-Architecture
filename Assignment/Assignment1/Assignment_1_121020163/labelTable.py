class LabelSet:
    def __init__(self):
        self.labels = {}

    def get_address(self, label: str):
        if label in self.labels.keys():
            return self.labels[label]
        return

    def set_label(self, label: str, address: int):
        self.labels[label] = address
        return

    def get_labels(self):
        return self.labels.keys()
