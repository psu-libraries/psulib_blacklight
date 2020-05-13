const etasSlots = document.querySelectorAll("[data-etas-oclc]");

const hathiETAS = () => {
    etasSlots.forEach(async (etasSlot) => {
        const oclcNumberFirst = etasSlot.dataset.etasOclc;

        if (oclcNumberFirst !== "") {
            let response = await fetch(`/etas/${oclcNumberFirst}`);
            let etasLink = await response.json();

            let metadataHTML = document.querySelector(`[data-etas-oclc='${oclcNumberFirst}']`);
            metadataHTML.innerHTML = etasLink;
        }
    });
};

export default hathiETAS;