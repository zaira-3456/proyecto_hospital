// file_picker.js – requerido por Flutter Web para FilePicker

window.filePicker = {
  pickFiles: async function(accept, multiple) {
    return new Promise((resolve) => {
      const input = document.createElement("input");
      input.type = "file";
      input.multiple = multiple || false;
      if (accept) input.accept = accept;

      input.onchange = (e) => {
        const files = e.target.files;
        const results = [];

        for (let i = 0; i < files.length; i++) {
          results.push({
            name: files[i].name,
            size: files[i].size,
            bytes: null, // Flutter convertirá esto luego
          });
        }

        resolve(results);
      };

      input.click();
    });
  }
};
